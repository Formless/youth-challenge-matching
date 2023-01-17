require 'csv'
require "active_support"
require "active_support/core_ext/hash/indifferent_access"

# quick and dirty matcher for youth challenge matches

class Matcher
  attr_accessor :data
  attr_accessor :competition_day
  attr_accessor :athletes
  attr_accessor :matches
  attr_accessor :unmatched_athletes

  def initialize(options)
    self.data = CSV.parse(File.read(options[:file]), headers: true)
    self.competition_day = options[:competition_day]
    self.matches = []
    self.unmatched_athletes = []
  end

  # organize athlete data
  def create_athletes
    athletes = []
    current_id = 1
    data.each do |row|
      athletes << Athlete.new(
        id: current_id,
        last_name: row["Last Name"],
        first_name: row["First Name"],
        gym_name: row["Gym Name"],
        gender: row["Gender"].downcase,
        age: row["Age"].to_i,
        age_on_competition: row["Age on #{competition_day}"].to_i,
        height: row["Height (I.E. 5'10\")"].to_f,
        weight: row["Weight (Lbs.) No Weight Cuttings"].to_f,
        number_of_exhibitions: row["Number of Exhibition Bouts"].to_i,
        number_of_amateur_bouts: row["Number of Amateur Bouts"].to_i
      )
      current_id += 1
    end
    self.athletes = athletes
  end

  # output recommended matches
  # separated by sex
  # within 1 year of age
  # within 10 lbs
  # close in height
  # within 2 bouts of exp
  # similar amateur record first, then exhibition
  # at least 1 match per athlete

  def match!
    self.unmatched_athletes = athletes
    sex_divisions = ["male", "female"]

    # match per division
    sex_divisions.each do |sex_division|
      available_athletes = athletes.select{ |a| a.gender == sex_division }
      while(available_athletes.length > 1)
        selected_athlete = available_athletes.shift
        if available_athletes.length > 0
          match_values = available_athletes.map{ |a| selected_athlete.matchup(a) }.compact.sort_by{ |x| x[:heuristic] }
          best_match = match_values.last
          matches << [selected_athlete, best_match[:athlete]]
          self.unmatched_athletes.delete_if { |x| x.id == selected_athlete.id}
          self.unmatched_athletes.delete_if { |x| x.id == best_match[:athlete].id}
          available_athletes.delete_if { |x| x.id == selected_athlete.id}
          available_athletes.delete_if { |x| x.id == best_match[:athlete].id}
        end
      end
    end
  end

  def print_data
    p '-------ATHLETES-------'
    athletes.each do |a|
      p "#{a.last_name}, #{a.first_name}"
    end
    p '-------MATCHES--------'
    match!
    matches.each do |a|
      p "[#{a[0].last_name}, #{a[0].first_name}] VS [#{a[1].last_name}, #{a[1].first_name}]"
    end
    p '------UNMATCHED-------'
    unmatched_athletes.each do |a|
      p "#{a.last_name}, #{a.first_name}"
    end
  end
end

class Athlete
  attr_accessor :id
  attr_accessor :last_name
  attr_accessor :first_name
  attr_accessor :gym_name
  attr_accessor :age
  attr_accessor :gender
  attr_accessor :age_on_competition
  attr_accessor :height
  attr_accessor :weight
  attr_accessor :number_of_exhibitions
  attr_accessor :number_of_amateur_bouts

  def initialize(options)
    self.id = options[:id]
    self.last_name = options[:last_name]
    self.first_name = options[:first_name]
    self.gym_name = options[:gym_name]
    self.age = options[:age]
    self.gender = options[:gender]
    self.age_on_competition = options[:age_on_competition]
    self.height = options[:height]
    self.weight = options[:weight]
    self.number_of_exhibitions = options[:number_of_exhibitions]
    self.number_of_amateur_bouts = options[:number_of_amateur_bouts]
  end

  def matchup(athlete)
    return if athlete.id == id

    heuristic = 0
    age_difference = (athlete.age_on_competition - age_on_competition).abs
    if age_difference <= 1
      heuristic += 100
    elsif age_difference <= 2
      heuristic += 50
    end

    weight_difference = (athlete.weight - weight).abs
    if weight_difference <= 5
      heuristic += 110
    elsif weight_difference <= 10
      heuristic += 100
    elsif weight_difference <= 20
      heuristic += 50
    elsif weight_difference <= 30
      heuristic += 30
    else
      heuristic -= 30
    end

    if athlete.height == height
      heuristic += 100
    else
      heuristic += 100 / ((athlete.height - height + 1)/6 + 1).abs
    end

    amateur_bout_difference = (athlete.number_of_amateur_bouts - number_of_amateur_bouts).abs
    exhibition_bout_difference = (athlete.number_of_exhibitions - number_of_exhibitions).abs

    if number_of_amateur_bouts > 0 && athlete.number_of_amateur_bouts > 0
      heuristic += 100 if (amateur_bout_difference).abs <= 2
    elsif number_of_amateur_bouts > 0
      heuristic += 100 if (athlete.number_of_exhibitions - total_bouts).abs <= 2
    elsif athlete.number_of_amateur_bouts > 0
      heuristic += 100 if (number_of_exhibitions - (athlete.total_bouts) + 1).abs <= 2
    else
      heuristic += 100 if (exhibition_bout_difference).abs <= 2
    end

    { heuristic: heuristic, athlete: athlete }
  end

  def total_bouts
    number_of_amateur_bouts + number_of_exhibitions
  end
end

matcher = Matcher.new(file: 'sample.csv', competition_day: "1/29/2023")
matcher.create_athletes
matcher.print_data