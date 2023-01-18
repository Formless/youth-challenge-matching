# Youth Challenge Athlete matcher

## Summary

A quick script to help match athletes competing in a combat sports event.

This is a ruby script that uses the `CSV`, `ActiveSupport`, and `Athlete` classes to match athletes based on certain criteria. The script reads in data from a CSV file, creates Athlete objects for each row of data, and then uses the match! method to match the athletes based on their gender, age, height, weight, number of exhibitions and amateur bouts.

The `match!` method first separates the athletes by gender, then while there are still two or more athletes available in the division it selects an athlete, then it uses the `Athlete` class's matchup method to find the best match based on the criteria mentioned before. The script also keeps track of the matches and unmatched athletes.

The script also includes a `print_data` method that prints out the list of athletes, the matches, and the unmatched athletes.

It's a basic script that uses simple `heuristics` to find matches between athletes, it could be improved with more advanced algorithms and more criteria for the matching process.

## Private packages in GitHub Packages

Rails Backend uses private npm packages in [GitHub Packages] so you'll need to
setup npm authentication. Instructions for doing so are here:

https://github.com/customink/pigment/blob/master/docs/authenticate-private-packages.md

## Installation and Requirements



Install Ruby(v3.0.3), then

    bundle
    ruby matcher.rb