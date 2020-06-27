# Codeowners

Simple CLI to interact with GitHub CODEOWNERS.

## Installation

Install as:

```shell
$ gem install codeowners
```

## Usage

### List

List code owners for a file, if any.

```shell
$ codeowners list path/to/file
@company/team-a @company/team-b
```

### Contributors

List code contributors for a file.
This is useful to guess who can be a candidate to own a file.

```shell
$ codeowners contributors path/to/file
path/to/file

Person One <person.one@company.com> / +106, -0
Person Two <person.two@company.com> / +12, -2
```

The command accepts also a pattern to match files in bulk.

```shell
$ codeowners contributors 'path/to/**/*.rb'
path/to/**/*.rb

Person One <person.one@company.com> / +243, -438
Person Three <person.three@company.com> / +104, -56
Person Two <person.two@company.com> / +12, -2
```

### Help

For a complete set of options, please run:

```shell
$ codeowners --help
$ codeowners COMMAND --help
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To run `codeowners` executable during development:

```shell
$ bundle exec exe/codeowners contributors path/to/file --base-directory=/path/to/git/repository/to/analyze
```

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jodosha/codeowners.

## Copyright

&copy; 2020 - Luca Guidi - https://lucaguidi.com
