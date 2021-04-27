# configuration



Automatic YAML configuration loader for Galileo.

# About
Any web app needs different configuration for development and production. This plugin will search
for a `config/default.yaml` file. If it is found, configuration from it is loaded into `app.configuration`.
Then, it will look for a `config/$GALILEO_ENV` file. (i.e. config/development.yaml). If this found, all of its
configuration be loaded, and will override anything loaded from the `default.yaml` file. This allows for your
app to work under different conditions without you re-coding anything. :)

# Installation
In `pubspec.yaml`:

```yaml
dependencies:
    galileo_configuration: ^2.0.0
```

# Usage

**Example Configuration**
```yaml
# Define normal YAML objects
some_key: foo
this_is_a_map:
  a_string: "string"
  another_string: "string"
  
```

You can also load configuration from the environment:
```yaml
# Loaded from the environment
system_path: $PATH
```

If a `.env` file is present in your configuration directory (i.e. `config/.env`), then it will be loaded before
applying YAML configuration.

You can also include values from one file into another:
```yaml
_include:
  - "./include-prod.yaml"
  - "./include-misc.yaml"
_include: "just-one-file.yaml"
```

**Server-side**
Call `configuration()`. The loaded configuration will be available in your application's
`configuration` map.

`configuration` also accepts a `sourceDirectory` or `overrideEnvironmentName` parameter.
The former will allow you to search in a directory other than `config`, and the latter lets you
override `$GALILEO_ENV` by specifying a specific configuration name to look for (i.e. `production`).

This package uses
[`package:merge_map`](https://github.com/thosakwe/merge_map)
internally, so existing configurations can be deeply merged.

Example:

```yaml
# default.yaml
foo:
  bar: baz
  quux: hello
  
# production.yaml
foo:
  quux: goodbye
  yellow: submarine
  
# Propagates to:
foo:
  bar: baz
  quux: goodbye
  yellow: submarine
```
