module Tests exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, conditional, int, list, string)
import Regex
import Test exposing (..)
import Tuple
import Validator


type alias Status =
    { name : String
    , age : Int
    }


type alias Named x =
    { x | name : String }


type alias AgeOf x =
    { x | age : Int }


type alias Error =
    ( String, String )


isOk : Result e a -> Bool
isOk x =
    case x of
        Ok _ ->
            True

        Err _ ->
            False


validate : List (Validator.Rule Error Status) -> Status -> Bool
validate rules =
    isOk << Validator.validate rules


require : Validator.Rule Error (Named x)
require =
    Validator.rule
        { field = .name
        , method = String.isEmpty
        , validWhen = False
        , error = ( "name", "Name is required" )
        }


mixLowercase : Validator.Rule Error (Named x)
mixLowercase =
    Validator.rule
        { field = .name
        , method = Regex.contains (Regex.regex "[a-z]+")
        , validWhen = True
        , error = ( "name", "Name must contains lowercase" )
        }


gt : Validator.Rule Error (AgeOf x)
gt =
    Validator.rule
        { field = .age
        , method = (<) 0
        , validWhen = True
        , error = ( "age", "Age is greater than 0" )
        }


getError : String -> Result (List Error) subject -> Error
getError key result =
    case result of
        Ok _ ->
            ( "", "" )

        Err errors ->
            List.filter (\( k, _ ) -> key == k) errors
                |> List.head
                |> Maybe.withDefault ( "", "" )


suite : Test
suite =
    describe "The Validator module"
        [ describe "Validator.validate"
            [ test "validate with empty rules" <|
                \() ->
                    Expect.equal True (validate [] { name = "ami", age = 17 })
            , test "validate valid status with single rule" <|
                \() ->
                    Expect.equal True (validate [ require ] { name = "ami", age = 17 })
            , test "validate valid status with some rules" <|
                \() ->
                    Expect.equal True (validate [ require, gt ] { name = "123", age = 17 })
            , test "validate invalid status with single rule" <|
                \() ->
                    Expect.equal False (validate [ require ] { name = "", age = 17 })
            , test "validate invalid status with some rules" <|
                \() ->
                    Expect.equal False (validate [ require, gt ] { name = "123", age = 0 })
            , test "get error message with single rule" <|
                \() ->
                    let
                        error =
                            Validator.validate [ require ] { name = "", age = 17 }
                                |> getError "name"
                    in
                    Expect.equal "Name is required" (Tuple.second error)
            , test "get error message with some rule" <|
                \() ->
                    let
                        error =
                            Validator.validate [ require, mixLowercase ] { name = "", age = 17 }
                                |> getError "name"
                    in
                    Expect.equal "Name must contains lowercase" (Tuple.second error)
            ]
        ]
