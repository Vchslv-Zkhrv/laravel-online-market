#!/usr/bin/env perl

use strict;
use warnings;
use utf8;

use HTTP::Tiny;
use HTML::TreeBuilder;
use Image::Grab;
use JSON;
use Encode;


my $URL = 'https://www.castorama.ru';


`rm -rf scrapped`;
`mkdir scrapped`;
chdir("scrapped");


sub get_tree {

  my $http = HTTP::Tiny->new();
  my $response = $http->get($_[0]);
  my $tree = HTML::TreeBuilder->new();
  $tree->parse($response->{content});

  return $tree;

}


sub save_image {

  print "$_[0] $_[1]\n";

  my $pic = Image::Grab->new();
  $pic->url($_[0]);
  $pic->grab;
  open(IMAGE, ">$_[1]") || die $!;
  binmode IMAGE;
  print IMAGE $pic->image;
  close IMAGE;

}


sub scrap_product {

  for (my $i=0; $i<=$_[0]; $i++) { print "--"; }
  print $_[3];
  print "\n";

  `mkdir '$_[3]'`;
  chdir($_[3]);

  save_image($_[2], 'cover.jpg');
  my $tree = get_tree($_[1]);

  my $price = ($tree->look_down( '_tag', 'span', class => qr/^price$/ ))[0]->as_text;
  my $sku = (($tree->look_down( '_tag', 'div', class => qr/^product\-essential__sku$/ ))[0]->look_down( '_tag', 'span' ))[0]->as_text;
  $price = substr $price, 0, -10;
  $price =~ tr/ //ds;

  my %specs = ();
  my $table = (($tree->look_down( '_tag', 'div', id => qr/^specifications$/ ))[0]->look_down( '_tag', 'dl' ))[0];
  my @table_labels = $table->look_down( '_tag', 'dt' );
  my @table_values = $table->look_down( '_tag', 'dd' );
  my $len = @table_values;
  for (my $i=0; $i<$len; $i++) {
    my $label = $table_labels[$i]->as_text;
    $label = decode('UTF-8', $label);
    my $value = $table_values[$i]->as_text;
    $value = decode('UTF-8', $value);
    %specs = (
      %specs,
      $label => $value
    )
  }


  my $json = {
      price => $price + 0,
      sku => $sku + 0,
      specs => \%specs
  };
  open(my $json_file, '>', 'data.json');
  print {$json_file} encode_json($json);
  close $json_file;

  chdir('..');
}


sub scrap_products_grid {

  my $tree = get_tree($_[1]);
  my @product_links = $tree->look_down( '_tag', 'a', class => qr/^product\-card__img\-link$/ );

  foreach my $plink (@product_links) {
    my $href = $URL . $plink->attr('href');
    my $img = $plink->look_down('_tag', 'img');
    my $src = $URL . $img->attr('data-src');
    my $name = $img->attr('alt');

    eval {
      scrap_product($_[0], $href, $src, $name);
    };
    if ($@) {
      print "$name: FAIL";
      `rm -rf '$name'`;
    }

  }
}


sub scrap_category {

  for (my $i=0; $i<$_[0]; $i++) { print "--"; }
  print $_[2];
  print "\n";

  `mkdir '$_[2]'`;
  chdir($_[2]);

  save_image($_[3], 'cover.jpg');
  if ($_[0] < $_[1] ) {
    scrap_catalogue($_[0]+1, $_[0], $_[4]);
  }
  else {
    scrap_products_grid($_[0], $_[4]);
  }

  chdir("..");

}


sub scrap_catalogue {

  my $tree = get_tree($_[2]);
  my @categories_links = $tree->look_down( '_tag', 'a', class => qr/^category__link$/ );

  foreach my $clink (@categories_links) {
    my $href = $URL . $clink->attr('href');
    my $img = $clink->look_down('_tag', 'img');
    my $src = $URL . $img->attr('data-src');
    my $name = $img->attr('alt');
    scrap_category($_[0], $_[1], $name, $src, $href );
  }
}


scrap_catalogue(0, 1, "$URL/catalogue");


1;
