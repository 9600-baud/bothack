use strict;
use warnings;
use Mojolicious::Lite;
use MIME::Base64;
use LWP::Simple;

get '/' => sub {
	my $c = shift;

	my $title = $c->param("text");
	$title = get("http://textb.org/r/$title/") if $title && $c->param('textb');
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
			<dd><code>/?say=1&amp;where=<em>.-channel</em>&amp;text=<em>hello</em></code></dd>
			<dt>ctcp action in channel</dt>
			<dd><code>/?act=1&amp;where=<em>.-channel</em>&amp;text=<em>dances</em></code></dd>
			<dt>mode change in channel</dt>
			<dd><code>/?mode=<em>+o</em>&amp;where=<em>.-channel</em>&amp;text=<em>Guest72826</em></code></dd>
			<dt>title (topic) change in channel</dt>
			<dd><code>/?title=1&amp;where=<em>.-channel</em>&amp;text=<em>title</em></code><br /><small>optionally use topic instead of title</small></dd>
			<dt>kick in channel</dt>
			<dd><code>/?kick=<em>Guest7277</em>&amp;where=<em>.-channel</em>&amp;text=<em>Reason.</em></code></dd>
			<dt>quit</dt>
			<dd><code>/?quit=1&amp;text=<em>Message.</em></code></dd>
			<dt>nick</dt>
			<dd><code>/?nick=1&amp;text=<em>CleverNick</em></code></dd>
			<dt>join</dt>
			<dd><code>/?join=1&amp;where=<em>.-someChannel</em></code></dd>
			<dt>part</dt>
			<dd><code>/?part=1&amp;where=<em>.-someChannel</em></code></dd>
			<dt>base64 encoded <code>?text=</code></dt>
			<dd>append <code>&amp;base64=1</code></dd>
			<dt><code>?text=</code> from <a href="https://textb.org">textb.org</a></dt>
			<dd>append <code>&amp;textb=1</code>, put the id of the page you want to view in <code>&amp;text=<em>id</em></code></dd>
		</dl>
		<p>The <a href="https://github.com/9600-baud/bothack/blob/master/irctest.pl">source</a> of all evil.</p>
	</body>
</html>
