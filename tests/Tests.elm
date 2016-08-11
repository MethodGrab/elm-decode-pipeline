module Tests exposing (..)

import ElmTest exposing (..)
import String
import Json.Decode.Pipeline as Pipeline
import Json.Decode as Json


decode : String -> Json.Decoder a -> Result String a
decode =
  flip Json.decodeString


all : Test
all =
  suite
    "Json.Decode.Pipeline"
    [ Pipeline.decode (,)
        |> Pipeline.required "a" Json.string
        |> Pipeline.required "b" Json.string
        |> decode """{"a":"foo","b":"bar"}"""
        |> assertEqual (Ok ( "foo", "bar" ))
        |> test "should decode basic example"
    , Pipeline.decode (,)
        |> Pipeline.requiredAt [ "a" ] Json.string
        |> Pipeline.requiredAt [ "b", "c" ] Json.string
        |> decode """{"a":"foo","b":{"c":"bar"}}"""
        |> assertEqual (Ok ( "foo", "bar" ))
        |> test "should decode requiredAt fields"
    , Pipeline.decode (,)
        |> Pipeline.optionalAt [ "a", "b" ] Json.string "--"
        |> Pipeline.optionalAt [ "x", "y" ] Json.string "--"
        |> decode """{"a":{},"x":{"y":"bar"}}"""
        |> assertEqual (Ok ( "--", "bar" ))
        |> test "should decode optionalAt fields"
    , Pipeline.decode (,)
        |> Pipeline.optional "a" Json.string "--"
        |> Pipeline.optional "x" Json.string "--"
        |> decode """{"x":"five"}"""
        |> assertEqual (Ok ( "--", "five" ))
        |> test "optional succeeds if the field is not present"
    , Pipeline.decode (,)
        |> Pipeline.optional "a" Json.string "--"
        |> Pipeline.optional "x" Json.string "--"
        |> decode """{"a":null,"x":"five"}"""
        |> assertEqual (Ok ( "--", "five" ))
        |> test "optional succeeds if the field is present but null"
    , Pipeline.decode (,)
        |> Pipeline.optional "a" Json.string "--"
        |> Pipeline.optional "x" Json.string "--"
        |> decode """{"x":5}"""
        |> assertEqual (Err "A `customDecode` failed with the message: Expecting a String but instead got: 5")
        |> test "optional fails if the field is present but doesn't decode"
    , Pipeline.decode (,)
        |> Pipeline.optionalAt [ "a", "b" ] Json.string "--"
        |> Pipeline.optionalAt [ "x", "y" ] Json.string "--"
        |> decode """{"a":{},"x":{"y":5}}"""
        |> assertEqual (Err "A `customDecode` failed with the message: Expecting a String but instead got: 5")
        |> test "optionalAt fails if the field is present but doesn't decode"
    , Pipeline.decode Err
        |> Pipeline.required "error" Json.string
        |> Pipeline.resolveResult
        |> decode """{"error":"invalid"}"""
        |> assertEqual (Err "A `customDecode` failed with the message: invalid")
        |> test "resolveResult bubbles up decoded Err results"
    , Pipeline.decode Ok
        |> Pipeline.required "ok" Json.string
        |> Pipeline.resolveResult
        |> decode """{"ok":"valid"}"""
        |> assertEqual (Ok "valid")
        |> test "resolveResult bubbles up decoded Ok results"
    ]
