[![Gem Version](https://badge.fury.io/rb/dont-overstay.svg)](https://badge.fury.io/rb/dont-overstay)

## What
This is a simple base gem for calculating number of days stayed in a country (for nomads).

Resident status (for tax purposes), revolves around being in a country for more than 180 calendar days.

The way this script looks at it, as it monitors the last checkin.

## Disclaimer
This is ALPHA quality software

## Installing
```bash
gem install dont-overstay
```

## Code
```ruby
require 'dont-overstay'

d = Daytracker.new
# This accepts timestamps, otherwise it will by default return the last years
# before (check before a date or current date)
# after (check after a date or exactly 1 year ago)
puts d.query
```
## Building
```bash
gem build dont-overstay.gemspec
gem install dont-overstay-0.0.1.gem
```
