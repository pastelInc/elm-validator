# elm-validator [![CircleCI](https://circleci.com/gh/pastelInc/elm-validator/tree/master.svg?style=svg)](https://circleci.com/gh/pastelInc/elm-validator/tree/master)

Provide a validator for elm.

## Features

- Custom validation
- Multiple validations per field
- Validations based on multiple fields

## Installation

    elm install pastelInc/elm-validator

## Usage

Export two functions and one type.

- `Rule` is validation rule.
- `rule` return `Rule`.
- `validate` return `Result (List error) subject` that is validated `subject`.

```elm
import Validator exposing (Rule, rule, validate)


ageValidator : Rule String { age : Int }
ageValidator =
    rule
        { field = .age
        , method = (>) 18
        , validWhen = True
        , error = "Age must be greater than 18."
        }

isValidAge : { age : Int } -> Bool
isValidAge model =
    case validate [ ageValidator ] model of
        Ok _ ->
            True

        Err _ ->
            False

ageErrors : { age : Int } -> List String
ageErrors model =
    case validate [ ageValidator ] model of
        Ok _ ->
            []

        Err es ->
            es
```

## Tests

    npm install -g elm-test@0.19.0-beta4
    elm-test

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## License

MIT
