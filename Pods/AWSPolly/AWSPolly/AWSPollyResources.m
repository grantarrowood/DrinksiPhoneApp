//
// Copyright 2010-2017 Amazon.com, Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.
// A copy of the License is located at
//
// http://aws.amazon.com/apache2.0
//
// or in the "license" file accompanying this file. This file is distributed
// on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
// express or implied. See the License for the specific language governing
// permissions and limitations under the License.
//

#import "AWSPollyResources.h"
#import <AWSCore/AWSCocoaLumberjack.h>

@interface AWSPollyResources ()

@property (nonatomic, strong) NSDictionary *definitionDictionary;

@end

@implementation AWSPollyResources

+ (instancetype)sharedInstance {
    static AWSPollyResources *_sharedResources = nil;
    static dispatch_once_t once_token;

    dispatch_once(&once_token, ^{
        _sharedResources = [AWSPollyResources new];
    });

    return _sharedResources;
}

- (NSDictionary *)JSONObject {
    return self.definitionDictionary;
}

- (instancetype)init {
    if (self = [super init]) {
        //init method
        NSError *error = nil;
        _definitionDictionary = [NSJSONSerialization JSONObjectWithData:[[self definitionString] dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:kNilOptions
                                                                  error:&error];
        if (_definitionDictionary == nil) {
            if (error) {
                AWSDDLogError(@"Failed to parse JSON service definition: %@",error);
            }
        }
    }
    return self;
}

- (NSString *)definitionString {
    return @"{\
  \"version\":\"2.0\",\
  \"metadata\":{\
    \"apiVersion\":\"2016-06-10\",\
    \"endpointPrefix\":\"polly\",\
    \"protocol\":\"rest-json\",\
    \"serviceFullName\":\"Amazon Polly\",\
    \"signatureVersion\":\"v4\",\
    \"uid\":\"polly-2016-06-10\"\
  },\
  \"operations\":{\
    \"DeleteLexicon\":{\
      \"name\":\"DeleteLexicon\",\
      \"http\":{\
        \"method\":\"DELETE\",\
        \"requestUri\":\"/v1/lexicons/{LexiconName}\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"DeleteLexiconInput\"},\
      \"output\":{\"shape\":\"DeleteLexiconOutput\"},\
      \"errors\":[\
        {\"shape\":\"LexiconNotFoundException\"},\
        {\"shape\":\"ServiceFailureException\"}\
      ],\
      \"documentation\":\"<p>Deletes the specified pronunciation lexicon stored in an AWS Region. A lexicon which has been deleted is not available for speech synthesis, nor is it possible to retrieve it using either the <code>GetLexicon</code> or <code>ListLexicon</code> APIs.</p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/managing-lexicons.html\\\">Managing Lexicons</a>.</p>\"\
    },\
    \"DescribeVoices\":{\
      \"name\":\"DescribeVoices\",\
      \"http\":{\
        \"method\":\"GET\",\
        \"requestUri\":\"/v1/voices\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"DescribeVoicesInput\"},\
      \"output\":{\"shape\":\"DescribeVoicesOutput\"},\
      \"errors\":[\
        {\"shape\":\"InvalidNextTokenException\"},\
        {\"shape\":\"ServiceFailureException\"}\
      ],\
      \"documentation\":\"<p>Returns the list of voices that are available for use when requesting speech synthesis. Each voice speaks a specified language, is either male or female, and is identified by an ID, which is the ASCII version of the voice name. </p> <p>When synthesizing speech ( <code>SynthesizeSpeech</code> ), you provide the voice ID for the voice you want from the list of voices returned by <code>DescribeVoices</code>.</p> <p>For example, you want your news reader application to read news in a specific language, but giving a user the option to choose the voice. Using the <code>DescribeVoices</code> operation you can provide the user with a list of available voices to select from.</p> <p> You can optionally specify a language code to filter the available voices. For example, if you specify <code>en-US</code>, the operation returns a list of all available US English voices. </p> <p>This operation requires permissions to perform the <code>polly:DescribeVoices</code> action.</p>\"\
    },\
    \"GetLexicon\":{\
      \"name\":\"GetLexicon\",\
      \"http\":{\
        \"method\":\"GET\",\
        \"requestUri\":\"/v1/lexicons/{LexiconName}\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"GetLexiconInput\"},\
      \"output\":{\"shape\":\"GetLexiconOutput\"},\
      \"errors\":[\
        {\"shape\":\"LexiconNotFoundException\"},\
        {\"shape\":\"ServiceFailureException\"}\
      ],\
      \"documentation\":\"<p>Returns the content of the specified pronunciation lexicon stored in an AWS Region. For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/managing-lexicons.html\\\">Managing Lexicons</a>.</p>\"\
    },\
    \"ListLexicons\":{\
      \"name\":\"ListLexicons\",\
      \"http\":{\
        \"method\":\"GET\",\
        \"requestUri\":\"/v1/lexicons\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"ListLexiconsInput\"},\
      \"output\":{\"shape\":\"ListLexiconsOutput\"},\
      \"errors\":[\
        {\"shape\":\"InvalidNextTokenException\"},\
        {\"shape\":\"ServiceFailureException\"}\
      ],\
      \"documentation\":\"<p>Returns a list of pronunciation lexicons stored in an AWS Region. For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/managing-lexicons.html\\\">Managing Lexicons</a>.</p>\"\
    },\
    \"PutLexicon\":{\
      \"name\":\"PutLexicon\",\
      \"http\":{\
        \"method\":\"PUT\",\
        \"requestUri\":\"/v1/lexicons/{LexiconName}\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"PutLexiconInput\"},\
      \"output\":{\"shape\":\"PutLexiconOutput\"},\
      \"errors\":[\
        {\"shape\":\"InvalidLexiconException\"},\
        {\"shape\":\"UnsupportedPlsAlphabetException\"},\
        {\"shape\":\"UnsupportedPlsLanguageException\"},\
        {\"shape\":\"LexiconSizeExceededException\"},\
        {\"shape\":\"MaxLexemeLengthExceededException\"},\
        {\"shape\":\"MaxLexiconsNumberExceededException\"},\
        {\"shape\":\"ServiceFailureException\"}\
      ],\
      \"documentation\":\"<p>Stores a pronunciation lexicon in an AWS Region. If a lexicon with the same name already exists in the region, it is overwritten by the new lexicon. Lexicon operations have eventual consistency, therefore, it might take some time before the lexicon is available to the SynthesizeSpeech operation.</p> <p>For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/managing-lexicons.html\\\">Managing Lexicons</a>.</p>\"\
    },\
    \"SynthesizeSpeech\":{\
      \"name\":\"SynthesizeSpeech\",\
      \"http\":{\
        \"method\":\"POST\",\
        \"requestUri\":\"/v1/speech\",\
        \"responseCode\":200\
      },\
      \"input\":{\"shape\":\"SynthesizeSpeechInput\"},\
      \"output\":{\"shape\":\"SynthesizeSpeechOutput\"},\
      \"errors\":[\
        {\"shape\":\"TextLengthExceededException\"},\
        {\"shape\":\"InvalidSampleRateException\"},\
        {\"shape\":\"InvalidSsmlException\"},\
        {\"shape\":\"LexiconNotFoundException\"},\
        {\"shape\":\"ServiceFailureException\"},\
        {\"shape\":\"MarksNotSupportedForFormatException\"},\
        {\"shape\":\"SsmlMarksNotSupportedForTextTypeException\"}\
      ],\
      \"documentation\":\"<p>Synthesizes UTF-8 input, plain text or SSML, to a stream of bytes. SSML input must be valid, well-formed SSML. Some alphabets might not be available with all the voices (for example, Cyrillic might not be read at all by English voices) unless phoneme mapping is used. For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/how-text-to-speech-works.html\\\">How it Works</a>.</p>\"\
    }\
  },\
  \"shapes\":{\
    \"Alphabet\":{\"type\":\"string\"},\
    \"AudioStream\":{\
      \"type\":\"blob\",\
      \"streaming\":true\
    },\
    \"ContentType\":{\"type\":\"string\"},\
    \"DeleteLexiconInput\":{\
      \"type\":\"structure\",\
      \"required\":[\"Name\"],\
      \"members\":{\
        \"Name\":{\
          \"shape\":\"LexiconName\",\
          \"documentation\":\"<p>The name of the lexicon to delete. Must be an existing lexicon in the region.</p>\",\
          \"location\":\"uri\",\
          \"locationName\":\"LexiconName\"\
        }\
      }\
    },\
    \"DeleteLexiconOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
      }\
    },\
    \"DescribeVoicesInput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"LanguageCode\":{\
          \"shape\":\"LanguageCode\",\
          \"documentation\":\"<p> The language identification tag (ISO 639 code for the language name-ISO 3166 country code) for filtering the list of voices returned. If you don't specify this optional parameter, all available voices are returned. </p>\",\
          \"location\":\"querystring\",\
          \"locationName\":\"LanguageCode\"\
        },\
        \"NextToken\":{\
          \"shape\":\"NextToken\",\
          \"documentation\":\"<p>An opaque pagination token returned from the previous <code>DescribeVoices</code> operation. If present, this indicates where to continue the listing.</p>\",\
          \"location\":\"querystring\",\
          \"locationName\":\"NextToken\"\
        }\
      }\
    },\
    \"DescribeVoicesOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Voices\":{\
          \"shape\":\"VoiceList\",\
          \"documentation\":\"<p>A list of voices with their properties.</p>\"\
        },\
        \"NextToken\":{\
          \"shape\":\"NextToken\",\
          \"documentation\":\"<p>The pagination token to use in the next request to continue the listing of voices. <code>NextToken</code> is returned only if the response is truncated.</p>\"\
        }\
      }\
    },\
    \"ErrorMessage\":{\"type\":\"string\"},\
    \"Gender\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"Female\",\
        \"Male\"\
      ]\
    },\
    \"GetLexiconInput\":{\
      \"type\":\"structure\",\
      \"required\":[\"Name\"],\
      \"members\":{\
        \"Name\":{\
          \"shape\":\"LexiconName\",\
          \"documentation\":\"<p>Name of the lexicon.</p>\",\
          \"location\":\"uri\",\
          \"locationName\":\"LexiconName\"\
        }\
      }\
    },\
    \"GetLexiconOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Lexicon\":{\
          \"shape\":\"Lexicon\",\
          \"documentation\":\"<p>Lexicon object that provides name and the string content of the lexicon. </p>\"\
        },\
        \"LexiconAttributes\":{\
          \"shape\":\"LexiconAttributes\",\
          \"documentation\":\"<p>Metadata of the lexicon, including phonetic alphabetic used, language code, lexicon ARN, number of lexemes defined in the lexicon, and size of lexicon in bytes.</p>\"\
        }\
      }\
    },\
    \"InvalidLexiconException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>Amazon Polly can't find the specified lexicon. Verify that the lexicon's name is spelled correctly, and then try again.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"InvalidNextTokenException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The NextToken is invalid. Verify that it's spelled correctly, and then try again.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"InvalidSampleRateException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The specified sample rate is not valid.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"InvalidSsmlException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The SSML you provided is invalid. Verify the SSML syntax, spelling of tags and values, and then try again.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"LanguageCode\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"cy-GB\",\
        \"da-DK\",\
        \"de-DE\",\
        \"en-AU\",\
        \"en-GB\",\
        \"en-GB-WLS\",\
        \"en-IN\",\
        \"en-US\",\
        \"es-ES\",\
        \"es-US\",\
        \"fr-CA\",\
        \"fr-FR\",\
        \"is-IS\",\
        \"it-IT\",\
        \"ja-JP\",\
        \"nb-NO\",\
        \"nl-NL\",\
        \"pl-PL\",\
        \"pt-BR\",\
        \"pt-PT\",\
        \"ro-RO\",\
        \"ru-RU\",\
        \"sv-SE\",\
        \"tr-TR\"\
      ]\
    },\
    \"LanguageName\":{\"type\":\"string\"},\
    \"LastModified\":{\"type\":\"timestamp\"},\
    \"LexemesCount\":{\"type\":\"integer\"},\
    \"Lexicon\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Content\":{\
          \"shape\":\"LexiconContent\",\
          \"documentation\":\"<p>Lexicon content in string format. The content of a lexicon must be in PLS format.</p>\"\
        },\
        \"Name\":{\
          \"shape\":\"LexiconName\",\
          \"documentation\":\"<p>Name of the lexicon.</p>\"\
        }\
      },\
      \"documentation\":\"<p>Provides lexicon name and lexicon content in string format. For more information, see <a href=\\\"https://www.w3.org/TR/pronunciation-lexicon/\\\">Pronunciation Lexicon Specification (PLS) Version 1.0</a>.</p>\"\
    },\
    \"LexiconArn\":{\"type\":\"string\"},\
    \"LexiconAttributes\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Alphabet\":{\
          \"shape\":\"Alphabet\",\
          \"documentation\":\"<p>Phonetic alphabet used in the lexicon. Valid values are <code>ipa</code> and <code>x-sampa</code>.</p>\"\
        },\
        \"LanguageCode\":{\
          \"shape\":\"LanguageCode\",\
          \"documentation\":\"<p>Language code that the lexicon applies to. A lexicon with a language code such as \\\"en\\\" would be applied to all English languages (en-GB, en-US, en-AUS, en-WLS, and so on.</p>\"\
        },\
        \"LastModified\":{\
          \"shape\":\"LastModified\",\
          \"documentation\":\"<p>Date lexicon was last modified (a timestamp value).</p>\"\
        },\
        \"LexiconArn\":{\
          \"shape\":\"LexiconArn\",\
          \"documentation\":\"<p>Amazon Resource Name (ARN) of the lexicon.</p>\"\
        },\
        \"LexemesCount\":{\
          \"shape\":\"LexemesCount\",\
          \"documentation\":\"<p>Number of lexemes in the lexicon.</p>\"\
        },\
        \"Size\":{\
          \"shape\":\"Size\",\
          \"documentation\":\"<p>Total size of the lexicon, in characters.</p>\"\
        }\
      },\
      \"documentation\":\"<p>Contains metadata describing the lexicon such as the number of lexemes, language code, and so on. For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/managing-lexicons.html\\\">Managing Lexicons</a>.</p>\"\
    },\
    \"LexiconContent\":{\"type\":\"string\"},\
    \"LexiconDescription\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Name\":{\
          \"shape\":\"LexiconName\",\
          \"documentation\":\"<p>Name of the lexicon.</p>\"\
        },\
        \"Attributes\":{\
          \"shape\":\"LexiconAttributes\",\
          \"documentation\":\"<p>Provides lexicon metadata.</p>\"\
        }\
      },\
      \"documentation\":\"<p>Describes the content of the lexicon.</p>\"\
    },\
    \"LexiconDescriptionList\":{\
      \"type\":\"list\",\
      \"member\":{\"shape\":\"LexiconDescription\"}\
    },\
    \"LexiconName\":{\
      \"type\":\"string\",\
      \"pattern\":\"[0-9A-Za-z]{1,20}\",\
      \"sensitive\":true\
    },\
    \"LexiconNameList\":{\
      \"type\":\"list\",\
      \"member\":{\"shape\":\"LexiconName\"},\
      \"max\":5\
    },\
    \"LexiconNotFoundException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>Amazon Polly can't find the specified lexicon. This could be caused by a lexicon that is missing, its name is misspelled or specifying a lexicon that is in a different region.</p> <p>Verify that the lexicon exists, is in the region (see <a>ListLexicons</a>) and that you spelled its name is spelled correctly. Then try again.</p>\",\
      \"error\":{\"httpStatusCode\":404},\
      \"exception\":true\
    },\
    \"LexiconSizeExceededException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The maximum size of the specified lexicon would be exceeded by this operation.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"ListLexiconsInput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"NextToken\":{\
          \"shape\":\"NextToken\",\
          \"documentation\":\"<p>An opaque pagination token returned from previous <code>ListLexicons</code> operation. If present, indicates where to continue the list of lexicons.</p>\",\
          \"location\":\"querystring\",\
          \"locationName\":\"NextToken\"\
        }\
      }\
    },\
    \"ListLexiconsOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Lexicons\":{\
          \"shape\":\"LexiconDescriptionList\",\
          \"documentation\":\"<p>A list of lexicon names and attributes.</p>\"\
        },\
        \"NextToken\":{\
          \"shape\":\"NextToken\",\
          \"documentation\":\"<p>The pagination token to use in the next request to continue the listing of lexicons. <code>NextToken</code> is returned only if the response is truncated.</p>\"\
        }\
      }\
    },\
    \"MarksNotSupportedForFormatException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>Speech marks are not supported for the <code>OutputFormat</code> selected. Speech marks are only available for content in <code>json</code> format.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"MaxLexemeLengthExceededException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The maximum size of the lexeme would be exceeded by this operation.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"MaxLexiconsNumberExceededException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The maximum number of lexicons would be exceeded by this operation.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"NextToken\":{\"type\":\"string\"},\
    \"OutputFormat\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"json\",\
        \"mp3\",\
        \"ogg_vorbis\",\
        \"pcm\"\
      ]\
    },\
    \"PutLexiconInput\":{\
      \"type\":\"structure\",\
      \"required\":[\
        \"Name\",\
        \"Content\"\
      ],\
      \"members\":{\
        \"Name\":{\
          \"shape\":\"LexiconName\",\
          \"documentation\":\"<p>Name of the lexicon. The name must follow the regular express format [0-9A-Za-z]{1,20}. That is, the name is a case-sensitive alphanumeric string up to 20 characters long. </p>\",\
          \"location\":\"uri\",\
          \"locationName\":\"LexiconName\"\
        },\
        \"Content\":{\
          \"shape\":\"LexiconContent\",\
          \"documentation\":\"<p>Content of the PLS lexicon as string data.</p>\"\
        }\
      }\
    },\
    \"PutLexiconOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
      }\
    },\
    \"RequestCharacters\":{\"type\":\"integer\"},\
    \"SampleRate\":{\"type\":\"string\"},\
    \"ServiceFailureException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>An unknown condition has caused a service failure.</p>\",\
      \"error\":{\"httpStatusCode\":500},\
      \"exception\":true,\
      \"fault\":true\
    },\
    \"Size\":{\"type\":\"integer\"},\
    \"SpeechMarkType\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"sentence\",\
        \"ssml\",\
        \"viseme\",\
        \"word\"\
      ]\
    },\
    \"SpeechMarkTypeList\":{\
      \"type\":\"list\",\
      \"member\":{\"shape\":\"SpeechMarkType\"},\
      \"max\":4\
    },\
    \"SsmlMarksNotSupportedForTextTypeException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>SSML speech marks are not supported for plain text-type input.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"SynthesizeSpeechInput\":{\
      \"type\":\"structure\",\
      \"required\":[\
        \"OutputFormat\",\
        \"Text\",\
        \"VoiceId\"\
      ],\
      \"members\":{\
        \"LexiconNames\":{\
          \"shape\":\"LexiconNameList\",\
          \"documentation\":\"<p>List of one or more pronunciation lexicon names you want the service to apply during synthesis. Lexicons are applied only if the language of the lexicon is the same as the language of the voice. For information about storing lexicons, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/API_PutLexicon.html\\\">PutLexicon</a>.</p>\"\
        },\
        \"OutputFormat\":{\
          \"shape\":\"OutputFormat\",\
          \"documentation\":\"<p> The format in which the returned output will be encoded. For audio stream, this will be mp3, ogg_vorbis, or pcm. For speech marks, this will be json. </p>\"\
        },\
        \"SampleRate\":{\
          \"shape\":\"SampleRate\",\
          \"documentation\":\"<p> The audio frequency specified in Hz. </p> <p>The valid values for <code>mp3</code> and <code>ogg_vorbis</code> are \\\"8000\\\", \\\"16000\\\", and \\\"22050\\\". The default value is \\\"22050\\\". </p> <p> Valid values for <code>pcm</code> are \\\"8000\\\" and \\\"16000\\\" The default value is \\\"16000\\\". </p>\"\
        },\
        \"SpeechMarkTypes\":{\
          \"shape\":\"SpeechMarkTypeList\",\
          \"documentation\":\"<p>The type of speech marks returned for the input text.</p>\"\
        },\
        \"Text\":{\
          \"shape\":\"Text\",\
          \"documentation\":\"<p> Input text to synthesize. If you specify <code>ssml</code> as the <code>TextType</code>, follow the SSML format for the input text. </p>\"\
        },\
        \"TextType\":{\
          \"shape\":\"TextType\",\
          \"documentation\":\"<p> Specifies whether the input text is plain text or SSML. The default value is plain text. For more information, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/ssml.html\\\">Using SSML</a>.</p>\"\
        },\
        \"VoiceId\":{\
          \"shape\":\"VoiceId\",\
          \"documentation\":\"<p> Voice ID to use for the synthesis. You can get a list of available voice IDs by calling the <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/API_DescribeVoices.html\\\">DescribeVoices</a> operation. </p>\"\
        }\
      }\
    },\
    \"SynthesizeSpeechOutput\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"AudioStream\":{\
          \"shape\":\"AudioStream\",\
          \"documentation\":\"<p> Stream containing the synthesized speech. </p>\"\
        },\
        \"ContentType\":{\
          \"shape\":\"ContentType\",\
          \"documentation\":\"<p> Specifies the type audio stream. This should reflect the <code>OutputFormat</code> parameter in your request. </p> <ul> <li> <p> If you request <code>mp3</code> as the <code>OutputFormat</code>, the <code>ContentType</code> returned is audio/mpeg. </p> </li> <li> <p> If you request <code>ogg_vorbis</code> as the <code>OutputFormat</code>, the <code>ContentType</code> returned is audio/ogg. </p> </li> <li> <p> If you request <code>pcm</code> as the <code>OutputFormat</code>, the <code>ContentType</code> returned is audio/pcm in a signed 16-bit, 1 channel (mono), little-endian format. </p> </li> <li> <p>If you request <code>json</code> as the <code>OutputFormat</code>, the <code>ContentType</code> returned is audio/json.</p> </li> </ul> <p> </p>\",\
          \"location\":\"header\",\
          \"locationName\":\"Content-Type\"\
        },\
        \"RequestCharacters\":{\
          \"shape\":\"RequestCharacters\",\
          \"documentation\":\"<p>Number of characters synthesized.</p>\",\
          \"location\":\"header\",\
          \"locationName\":\"x-amzn-RequestCharacters\"\
        }\
      },\
      \"payload\":\"AudioStream\"\
    },\
    \"Text\":{\"type\":\"string\"},\
    \"TextLengthExceededException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The value of the \\\"Text\\\" parameter is longer than the accepted limits. The limit for input text is a maximum of 3000 characters total, of which no more than 1500 can be billed characters. SSML tags are not counted as billed characters.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"TextType\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"ssml\",\
        \"text\"\
      ]\
    },\
    \"UnsupportedPlsAlphabetException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The alphabet specified by the lexicon is not a supported alphabet. Valid values are <code>x-sampa</code> and <code>ipa</code>.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"UnsupportedPlsLanguageException\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"message\":{\"shape\":\"ErrorMessage\"}\
      },\
      \"documentation\":\"<p>The language specified in the lexicon is unsupported. For a list of supported languages, see <a href=\\\"http://docs.aws.amazon.com/polly/latest/dg/API_LexiconAttributes.html\\\">Lexicon Attributes</a>.</p>\",\
      \"error\":{\"httpStatusCode\":400},\
      \"exception\":true\
    },\
    \"Voice\":{\
      \"type\":\"structure\",\
      \"members\":{\
        \"Gender\":{\
          \"shape\":\"Gender\",\
          \"documentation\":\"<p>Gender of the voice.</p>\"\
        },\
        \"Id\":{\
          \"shape\":\"VoiceId\",\
          \"documentation\":\"<p>Amazon Polly assigned voice ID. This is the ID that you specify when calling the <code>SynthesizeSpeech</code> operation.</p>\"\
        },\
        \"LanguageCode\":{\
          \"shape\":\"LanguageCode\",\
          \"documentation\":\"<p>Language code of the voice.</p>\"\
        },\
        \"LanguageName\":{\
          \"shape\":\"LanguageName\",\
          \"documentation\":\"<p>Human readable name of the language in English.</p>\"\
        },\
        \"Name\":{\
          \"shape\":\"VoiceName\",\
          \"documentation\":\"<p>Name of the voice (for example, Salli, Kendra, etc.). This provides a human readable voice name that you might display in your application.</p>\"\
        }\
      },\
      \"documentation\":\"<p>Description of the voice.</p>\"\
    },\
    \"VoiceId\":{\
      \"type\":\"string\",\
      \"enum\":[\
        \"Geraint\",\
        \"Gwyneth\",\
        \"Mads\",\
        \"Naja\",\
        \"Hans\",\
        \"Marlene\",\
        \"Nicole\",\
        \"Russell\",\
        \"Amy\",\
        \"Brian\",\
        \"Emma\",\
        \"Raveena\",\
        \"Ivy\",\
        \"Joanna\",\
        \"Joey\",\
        \"Justin\",\
        \"Kendra\",\
        \"Kimberly\",\
        \"Salli\",\
        \"Conchita\",\
        \"Enrique\",\
        \"Miguel\",\
        \"Penelope\",\
        \"Chantal\",\
        \"Celine\",\
        \"Mathieu\",\
        \"Dora\",\
        \"Karl\",\
        \"Carla\",\
        \"Giorgio\",\
        \"Mizuki\",\
        \"Liv\",\
        \"Lotte\",\
        \"Ruben\",\
        \"Ewa\",\
        \"Jacek\",\
        \"Jan\",\
        \"Maja\",\
        \"Ricardo\",\
        \"Vitoria\",\
        \"Cristiano\",\
        \"Ines\",\
        \"Carmen\",\
        \"Maxim\",\
        \"Tatyana\",\
        \"Astrid\",\
        \"Filiz\",\
        \"Vicki\"\
      ]\
    },\
    \"VoiceList\":{\
      \"type\":\"list\",\
      \"member\":{\"shape\":\"Voice\"}\
    },\
    \"VoiceName\":{\"type\":\"string\"}\
  },\
  \"documentation\":\"<p>Amazon Polly is a web service that makes it easy to synthesize speech from text.</p> <p>The Amazon Polly service provides API operations for synthesizing high-quality speech from plain text and Speech Synthesis Markup Language (SSML), along with managing pronunciations lexicons that enable you to get the best results for your application domain.</p>\"\
}\
";
}

@end
