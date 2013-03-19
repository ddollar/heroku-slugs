require "heroku/command/base"
require "restclient"

class Heroku::Command::Slugs < Heroku::Command::Base

  # slugs:copy FROM TO
  #
  # copy a slugs from one app to another
  # both apps must already exist
  #
  #Example:
  #
  # $ heroku slugs:copy old-app-42 new-app-37
  #
  def copy
    from = shift_argument || error("must specify FROM app")
    to   = shift_argument || error("must specify TO app")

    action("Copying slug from #{from} to #{to}") do
      job = cisaurus["/v1/apps/#{from}/copy/#{to}"].post(json_encode("description" => "Copied from #{from}"), :content_type => :json).headers[:location]
      loop do
         sleep 1
         print "."
         break unless cisaurus[job].get.code == 202
      end
      print " "
    end
  end

private

  def cisaurus_host
    ENV["CISAURUS_HOST"] || "https://cisaurus.herokuapp.com"
  end

  def cisaurus
    RestClient::Resource.new(cisaurus_host, "", Heroku::Auth.api_key)
  end

end
