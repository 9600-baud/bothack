use strict;
use warnings;
use Mojolicious::Lite;
use MIME::Base64;
use LWP::Curl;

sub getfromtextb {
	return LWP::Curl->new()->get('http://textb.org/r/' . shift, '');
}

get '/' => sub {
	my $c = shift;

	my $title = $c->param("text");
	$title = getfromtextb($title) if $title && $c->param('textb');
	$title = decode_base64($title) if $title && $c->param('base64');

	my $where = $c->param('where');
	$where =~ s/\.-/#/g if $where;

	if ($c->param('say')) {
		$title = "I am a 'hacked' bot." unless $title;
		$title = "PRIVMSG $where :$title";
	} elsif ($c->param('act')) {
		$title = "is a 'hacked' bot" unless $title;
		$title = "PRIVMSG $where :\x01ACTION $title\x01";
	} elsif ($c->param('mode')) {
		my $mode = $c->param('mode');
		$title = "MODE $where $mode $title";
	} elsif ($c->param('title') or $c->param('topic')) {
		$title = "Title changed by 'hacked' bot." unless $title;
		$title = "TITLE $where :$title";
	} elsif ($c->param('kick')) {
		my $victim = $c->param('kick');
		$title = "Kicked by meeee!" unless $title;
		$title = "KICK $where $victim :$title";
	} elsif ($c->param('quit')) {
		$title = "Fix your IRC bot!" unless $title;
		$title = "QUIT :$title";
	} elsif ($c->param('nick')) {
		$title = "BadlyCodedBot" unless $title;
		$title = "NICK $title";
	} elsif ($c->param('join')) {
		$title = "JOIN ##not-a-honeypot";
		$title = "JOIN $where" if $where;
	} elsif ($c->param('part')) {
		$title = "PART $where" if $where;
	}

	if ($c->param('cr') && ! $c->param('lf')) {
		$title = "\x0d" . $title if $title;
	} elsif (! $c->param('cr') && $c->param('lf')) {
		$title = "\x0a" . $title if $title;
	} else {
		$title = "\x0d\x0a" . $title if $title;
	}
	
	$title = " IRC Url Title Grabbing Bot 'Hack'" unless $title;
	$c->stash(title => $title);
	$c->render;
} => 'index';

app -> start;
__DATA__

@@ index.html.ep
<!DOCTYPE html>
<html>
	<head>
		<title>:)<%= title %></title>
		<meta charset="utf-8" />
	</head>
	<body>
		<h3>How to use:</h3>
		<h4>Keep in mind, <code>?where=</code> replaces <code>.-</code> with <code>#</code>.</h4>
		<dl>
			<dt>raw irc commands</dt>
			<dd><code>/?text=<em>HELP</em></code></dd>
			<dt>say in channel</dt>
			<dd><code>/?say=1&where=<em>.channel</em>&text=<em>hello</em></code><br /><small><code>?text=</code> is optional</code></small></dd>
			<dt>ctcp action in channel</dt>
			<dd><code>/?act=1&where=<em>.channel</em>&text=<em>dances</em></code><br /><small><code>?text=</code> is optional</code></small></dd>
			<dt>mode change in channel</dt>
			<dd><code>/?mode=<em>+o</em>&where=<em>.channel</em>&text=<em>Guest72826</em></code></dd>
			<dt>title (topic) change in channel</dt>
			<dd><code>/?title=1&where=<em>.channel</em>&text=<em>title</em></code><br /><small><code>?text=</code> is optional. optionally use topic instead of title</small></dd>
			<dt>kick in channel</dt>
			<dd><code>/?kick=<em>Guest7277</em>&where=<em>.channel</em>&text=<em>Reason.</em></code><br /><small><code>?text=</code> is optional</code></small></dd>
			<dt>quit</dt>
			<dd><code>/?quit=1&text=<em>Message.</em></code><br /><small><code>?text=</code> is optional</small></dd>
			<dt>nick</dt>
			<dd><code>/?nick=1&text=<em>CleverNick</em></code></dd>
			<dt>join</dt>
			<dd><code>/?join=1&where=<em>.someChannel</em></code></dd>
			<dt>part</dt>
			<dd><code>/?part=1&where=<em>.someChannel</em></code></dd>
			<dt>base64 encoded <code>?text=</code></dt>
			<dd>append <code>&base64</code></dd>
		</dl>
	</body>
</html>
