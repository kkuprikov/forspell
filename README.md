# Forspell
Forspell is a spelling checker for your code documentation.

Supports C, C++, Ruby and Markdown files.

## Requirements
* [libhunspell] >= 1.2.0
* [ffi] ~> 1.0

## Installation

```
gem install forspell
```

## Usage

```
forspell lib *.md
```

### Available options

* `-e, --exclude`
Exclude some subdirectories or files.
For instance, `forspell lib *.md -e lib/skip_this LICENSE.md`

* `-d, --dictionary-name`
Use another hunspell dictionary from `lib/dictionaries` folder. Default is 'en_US'.

* `-c, --custom-dictionaries`
Use your own dictionary to prevent your project-specific slang reported as errors.

Format is `custom_word: existing_word`, please note that your `custom_word` will inherit plural form from `existing word`.

Or you could use just `custom_word`, therefore `custom_words` will be treated as an error.

Note: if you run `forspell` with `--format dictionary`, you could use the output as a base for your custom dictionary!

Please see `lib/forspell/ruby.dict` for more examples.

* `-f, --format`
Available formats: dictionary, readable, JSON, YAML. Default is 'readable'.

* `-l, --logfile`
Use the file instead of `STDERR`.
* `-v, --verbose`
Adds `Processing file: ...` for debug purposes.

### Examples
```
forspell lib -f dictionary > custom.dict
# Remove the actual errors from the custom.dict
forspell lib -c custom.dict
# Or, export errors for further analysis
forspell lib -c custom.dict -f json > result.json
```
Then fix typos in your docs :)


[libhunspell]: http://hunspell.sourceforge.net/
[ffi]: https://github.com/ffi/ffi
