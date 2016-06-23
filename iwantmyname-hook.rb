#!/usr/bin/env ruby

load File.dirname(__FILE__) + '/iwantmyname-secrets.rb'
require 'mechanize'
require 'date'
require 'pp'
require 'resolv'
require 'json'

DEBUG = false

hook_stage = ARGV[0]
domain = ARGV[1]
txt_challenge = ARGV[3]

exit unless %[deploy_challenge clean_challenge].include?(hook_stage)

hostname = ""

agent = Mechanize.new

agent.get('https://iwantmyname.com/') do |page|
  page = page.form_with(:action => '/signin') do |form|
    form.username = @username
    form.password = @password
  end.click_button

  page = agent.click(page.link_with(:text => /Domains/))

  domains = page.links_with(:href => /^\/dashboard\/domains\/edit\//).map(&:text)

  while ! domains.include?(domain)
    puts "Splitting #{domain}"
    start, domain = domain.split(/\./, 2)
    hostname += "#{"." unless hostname.empty?}#{start}"
    exit if domain.empty?
  end

  puts "Top domain is #{domain}"

  hostname = "_acme-challenge#{"." unless hostname.empty?}#{hostname}"

  page = agent.get("/dashboard/dns/#{domain}")

  # Required otherwise add will just remove everything but this!
  rrset_response = agent.get("/dashboard/dns/list/#{domain}/#{DateTime.now.strftime("%Q")}")
  rrset = JSON.parse(rrset_response.body)["rr"]
  pp rrset if DEBUG
  id = rrset.index { |rr| rr["type"] == "TXT" && rr["name"] == hostname }

  csrf_token = page.at('meta').attributes['content'].value

  headers = {
  "X-CSRF-Token" => csrf_token,
  }

  if hook_stage == "deploy_challenge"
    if id
      old_value = rrset[id]["value"]

      data = {
        "id" => id
      }

      puts "Removing TXT record for #{hostname}, was \"#{old_value}\""
      response = agent.post("/dashboard/dns/delete/#{domain}", data, headers)
    end

    data = {
      "name"  => hostname,
      "type"  => "TXT",
      "value" => txt_challenge,
      "prio"  => "",
      "ttl"   => 3600,
    }

    puts "Adding TXT record for #{hostname}, value of \"#{txt_challenge}\""
    response = agent.post("/dashboard/dns/add/#{domain}", data, headers)
  elsif hook_stage == "clean_challenge" && id
    old_value = rrset[id]["value"]

    data = {
      "id" => id
    }

    puts "Removing TXT record for #{hostname}, was \"#{old_value}\""
    response = agent.post("/dashboard/dns/delete/#{domain}", data, headers)
  end

  # Commit the data
  data = {
    "csrf_token" => csrf_token,
    "commit"     => "",
  }

  puts "Committing changes"
  response = agent.post("/dashboard/dns/commit/#{domain}", data)
end

if hook_stage == "deploy_challenge"
  dns = Resolv::DNS.new
  nameservers = [
    dns.getaddress('ns1.iwantmyname.net').to_s,
    dns.getaddress('ns2.iwantmyname.net').to_s,
    dns.getaddress('ns3.iwantmyname.net').to_s,
    dns.getaddress('ns4.iwantmyname.net').to_s,
  ]

  resolved = false

  until resolved
    dns = Resolv::DNS.new({:nameserver => [nameservers.sample], :search => '', :ndots => 1})
    pp dns if DEBUG

    puts "Trying to resolve #{hostname}.#{domain}"
    dns.each_resource("#{hostname}.#{domain}", Resolv::DNS::Resource::IN::TXT) do |resp|
      if resp.strings[0] == txt_challenge
        puts "Found #{resp.strings[0]}. match."
        resolved = true
      else
        puts "Found #{resp.strings[0]}. no match."
      end
    end

    if !resolved
     puts "Didn't find a match for #{txt_challenge}"
     puts "Waiting to retry"
     15.times { sleep 1; putc "."; }
     puts
    end
  end
end
