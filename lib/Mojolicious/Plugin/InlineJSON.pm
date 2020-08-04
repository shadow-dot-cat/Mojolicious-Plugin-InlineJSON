package Mojolicious::Plugin::InlineJSON;

our $VERSION = 0.1;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::ByteStream qw(b);
use Mojo::JSON qw(encode_json);
use Mojo::Util qw(xml_escape);

sub register {
  my ($self, $app) = @_;
  $app->helper(js_data => \&js_data);
  $app->helper(js_json_string => \&js_json_string);
  $app->helper(js_data_via_json => \&js_data_via_json);
}

sub _escape_tag { $_[0] =~ s/>/\\>/gr }

sub _js_data { _escape_tag(encode_json($_[1]))  }

sub _js_json_string { _escape_tag(encode_json(encode_json($_[1]))) }

# returns '{ "foo": 1 }'

sub js_data { b(&_js_data) }

# returns '"{ \"foo\": 1 }"'

sub js_json_string { b(&_js_json_string) }

# returns 'JSON.parse("{ \"foo\": 1 }")'

sub js_data_via_json { b('JSON.parse('.&_js_json_string.')') }

9201;

=encoding utf8

=head1 NAME
 
Mojolicious::Plugin::InlineJSON - Bootstrap your app with inline JSON

=head1 VERSION

0.1

=head1 SYNOPSIS

  # Mojolicious
  use Mojolicious;
  $app->plugin('InlineJSON');

  # Mojolicious::Lite
  plugin 'InlineJSON';

  # in your controller
  $c->stash(important_stuff => { data => [ ... ] });

  # then, in a template
  <script>
     // bootstrap with literal JSON
     var prerenderedData =  <%= js_data($important_stuff) %>
  </script>


=head1 DESCRIPTION

L<Mojolicious::Plugin::InlineJSON> is a L<Mojolicious plugin|Mojolicious::Plugin>
for rendering data to json in a template. This is useful for when
you want to serve content managed dynamically by javascript
without needing any extra AJAX calls after the page loads.

This plugin provides 3 different helpers for rendering JSON in a
variety of different ways.

=head1 HELPERS

=head2 js_data

  <script> 
    var prerenderedData = <%= js_data($important_stuff) %>
    // ...the rest of your JS
  </script>

C<js_data> will render the perl data structure passed to it into a
literal javascript structure, capable of beind directly consumed
by javascript.

In essence, it turns this

  { key => 'value' }

into 
 
  { key: 'value' }

while making sure to avoid any attribute escaping or accidental
tag closure.
