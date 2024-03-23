#!/usr/bin/env perl


# This script filles database with scrapped data
# The DB schema assumed to be already defined but database is empty
# Filles the following tables:
# - categories
# - subcategories
# - products
# - specs
# Images will be saved at PERL_VOLUME_PATH folder as <image_id>.jpg


use strict;
no warnings 'utf8';


use Encode;
use DBI;
use JSON;
use POSIX qw(strftime);


my $driver = 'Pg';
my $database = `echo \$PERL_DB_DATABASE` =~ s/\n//r;
my $username = `echo \$PERL_DB_USER` =~ s/\n//r;
my $password = `echo \$PERL_DB_PASSWORD` =~ s/\n//r;
my $volume_path = `echo \$PERL_VOLUME_PATH` =~ s/\n//r;
my $port = `echo \$PERL_DB_PORT` =~ s/\n//r;
my $host = '127.0.0.1';
my $dsn = "DBI:$driver:dbname=$database;host=$host;port=$port";
my $dt = strftime "%F %T", gmtime;


sub listdir {
  return split("\n", decode('UTF-8', `ls $_[0] | grep -v 'cover.jpg'`));
}


my $dbh = DBI->connect(
  $dsn,
  $username,
  $password,
  {
    RaiseError => 1,
    pg_utf8_flag => 1,
    pg_enable_utf8 => 1
  }
) or die $DBI::errstr;
print "Database opened successfully\n\n";


my $image_id = 1;
my $category_id = 1;
my $subcategory_id = 1;
my $product_id = 1;


my @categories = listdir('scrapped');

foreach my $c (@categories) {

  print "\n" . $c . "\n";
  my $stmt = qq(INSERT INTO categories (name, image_id, created_at) VALUES ('$c', $image_id, '$dt'));
  $dbh->do($stmt) or die $DBI::errstr;
  `cp 'scrapped/$c/cover.jpg' '$volume_path/$image_id.jpg'`;
  $image_id++;
  my @subcategories = listdir("'scrapped/$c'");

  foreach my $s (@subcategories) {

      print '--' . $s . "\n";
      my $stmt = qq(INSERT INTO subcategories (name, category_id, image_id, created_at) VALUES ('$s', $category_id, $image_id, '$dt'));
      $dbh->do($stmt) or die $DBI::errstr;
      `cp 'scrapped/$c/$s/cover.jpg' '$volume_path/$image_id.jpg'`;
      $image_id++;
      my @products = listdir("'scrapped/$c/$s'");

      foreach my $p (@products) {

        print '----' . $p . "\n";
        `cp 'scrapped/$c/$s/$p/cover.jpg' '$volume_path/$image_id.jpg'`;
        $image_id++;
        my $specs_str = '';
        open(FH, '<', "scrapped/$c/$s/$p/data.json") or die $!;
        while (<FH>) {

          my $product_data_str = decode_json $_;
          my %product_data = %{$product_data_str};
          my $stmt = qq(INSERT INTO products (name, sku, price, subcategory_id, image_id, created_at) VALUES ('$p', $product_data{sku}, $product_data{price}, $subcategory_id, $image_id, '$dt'));
          $dbh->do($stmt) or die $DBI::errstr;
          my $specs_ref = %product_data{specs};
          my %specs = %{$specs_ref};

          foreach my $k (keys %specs) {

            my $val = $specs{$k} =~ s/^\s+|\s+$//rg;
            my $key = $k =~ s/\n+//rg;
            $key = $key =~ s/\t+//rg;
            $key = $key =~ s/\?//rg;
            $key = $key =~ s/^\s+|\s+$//rg;
            my $stmt = qq(INSERT INTO specs (product_id, key, value, created_at) VALUES ($product_id, '$key', '$val', '$dt'));
            $dbh->do($stmt) or die $DBI::errstr;

          }

          last;

        }

        close FH;
        $product_id++;

      }

      $subcategory_id++;

  }

  $category_id++;

}


$dbh->disconnect();
print "\n\nDatabase closed successfully\n";


1;
