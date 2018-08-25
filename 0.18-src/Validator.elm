module Validator
    exposing
        ( Rule
        , rule
        , validate
        )

{-| This module supports validation.

@docs Rule
@docs rule
@docs validate

-}


{-| Validation rules. You can create rules what have any type of validation
method and error.
-}
type Rule error subject
    = Rule
        { method : subject -> Bool
        , validWhen : Bool
        , error : error
        }


{-| Create an rule.

    rule
        { field = .age
        , method = (>) 18
        , validWhen = True
        , error = "Age must be greater than 18."
        }

-}
rule :
    { field : subject -> field
    , method : field -> Bool
    , validWhen : Bool
    , error : error
    }
    -> Rule error subject
rule { field, method, validWhen, error } =
    Rule
        { method = method << field
        , validWhen = validWhen
        , error = error
        }


{-| Validate a subject using rules.

    validate
        [ rule
            { field = .age
            , method = (>) 18
            , validWhen = True
            , error = "Age must be greater than 18."
            }
        ]
        { age = 18 }

-}
validate : List (Rule error subject) -> subject -> Result (List error) subject
validate rules subject =
    List.foldl
        (flip updateValidation subject)
        (Ok subject)
        rules


updateValidation : Rule error subject -> subject -> Result (List error) subject -> Result (List error) subject
updateValidation ((Rule { error }) as rule) subject result =
    if validateField rule subject then
        result
    else
        updateError error result


updateError : error -> Result (List error) subject -> Result (List error) subject
updateError error result =
    let
        handleValidationError errors =
            error :: errors
    in
    case result of
        Ok subject ->
            Err [ error ]

        Err errors ->
            Result.mapError handleValidationError result


validateField : Rule error subject -> subject -> Bool
validateField (Rule model) subject =
    model.validWhen == model.method subject