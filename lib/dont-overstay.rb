require 'rest-client'
require 'json'

class Daytracker
  def initialize(tokenval=nil)
    apiver = '20160226'
    base_url = 'https://api.foursquare.com/v2/users/self/checkins'
    token = nil || tokenval || ENV['oauth_token']
    limit = 300
    if token != nil then
      @full_url = base_url + '?oauth_token=' + token + '&limit=' + limit.to_s + '&sort=oldestfirst&v=' + apiver
    end
  end

  def query(before=Time.now.to_i, after=((Date.today - 365).to_time.to_i), padded_days=0)
    if ENV['dryrun'] then
      if ENV['dryrun'] == "true" then
      return {:status => "Test", before: before, after: after, padded_days: (padded_days || 0)}
      end
    end
    country_list = []
    if @full_url != nil then
      if before.to_i + 3600 > Time.now.to_i then
        requested_url = @full_url + '&afterTimestamp=' + after.to_s + '&beforeTimestamp=' + before.to_s
        after_timestamp = after
        before_timestamp = before
        last_country_code = ""
        last_country_name = ""

        begin
          while (after_timestamp + 3600) < Time.now.to_i
            requested_url = @full_url + '&afterTimestamp=' + after_timestamp.to_s + '&beforeTimestamp=' + before_timestamp.to_s
            parsed_body = JSON.parse(RestClient.get(requested_url))
            meta = parsed_body["meta"]
            response = parsed_body["response"]
            checkins = response["checkins"]["items"]

            if meta["code"] == 200 then
              checkins.each{|checkin|
                if country_list.length == 0 then
                  country_list << {:visit => checkin["createdAt"].to_i, :code => checkin["venue"]["location"]["cc"].to_s, :name => checkin["venue"]["location"]["country"].to_s, length: padded_days.to_i}
                else
                  if country_list[country_list.length - 1][:code] == checkin["venue"]["location"]["cc"] then
                    # Work out days between the last checkin
                    days = (checkin["createdAt"] - country_list[country_list.length - 1][:visit]) / 86400
                    if days == 0 then
                      days = 1
                    end
                    country_list[country_list.length - 1][:length] = days.to_i # Set the number of days stayed here
                  else
                    # Then just create a new entry
                    country_list << {:visit => checkin["createdAt"].to_i, :code => checkin["venue"]["location"]["cc"].to_s, :name => checkin["venue"]["location"]["country"].to_s, length: padded_days.to_i}
                  end
                end
                after_timestamp = checkin["createdAt"].to_i + 1800 # Set the createdAt to after Timestamp
                last_country_code = checkin["venue"]["location"]["cc"].to_s
                last_country_name = checkin["venue"]["location"]["country"].to_s
              }
              if checkins.length == 0 then
                after_timestamp += 1800
              end
              #puts "Plus 1 hour: #{(after_timestamp + 3600).to_i} Current: #{Time.now.to_i}"
              #puts "---"

            else
              {:status => "Non 200 response from API"}
              break
            end
            # TODO: Set after_timestamp with the last checkin rather than 2419200 after the after_timestamp
            #after_timestamp = after_timestamp + (2419200 * 3)
          end
        rescue
          {:status => "Exception found #{$!}"}
        end
        days_since_last_ts = (Time.now.to_i - after_timestamp.to_i) / 86400
        {:status => "OK", countries: country_list, last_seen: {days: days_since_last_ts, country: {code: last_country_code, name: last_country_name}}}
      else
        {:status => "Before time is too soon"}
      end
    else
      {:status => "Please set an 'oauth_token' and try again"}
    end
  end
end
