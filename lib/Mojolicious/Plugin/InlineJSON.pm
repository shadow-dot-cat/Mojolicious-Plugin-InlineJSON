package Mojolicious::Plugin::InlineJSON;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json);

sub register {
  my ($self, $app) = @_;
  $app->helper(js_data => \&js_data);
  $app->helper(js_json_string => \&js_json_string);
  $app->helper(js_data_via_json => \&js_data_via_json);
}

sub _js_data { encode_json($_[1]) =~ s/>/\\>/gr }

sub _js_json_string { encode_json(&_js_data) }

# returns '{ "foo": 1 }'

sub js_data { b(&_js_data) }

# returns '"{ \"foo\": 1 }"'

sub js_json_string { b(&_js_json_string) }

# returns 'JSON.parse("{ \"foo\": 1 }")'

sub js_data_via_json { b('JSON.parse('.&_js_json_string.')') }

9201;
