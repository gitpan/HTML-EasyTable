# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-EasyTable.t'

#########################

use Test::More tests => 5;
BEGIN { use_ok( 'HTML::EasyTable' ); }
use CGI qw(:standard);
use Carp;
use strict;
mkdir 'examples' or croak "Cant create directory 'examples': $!";

############### 1
{
open(TEST1,'>','examples/Sample1.htm') or croak "Cant open test file: $!";
 my $table1 = HTML::EasyTable->new(
                -style=>'border: 2px black double;',
                -border=>1,
                -cellpadding=>2,
                -cellspacing=>0
               );
print TEST1 start_html("HTML::EasyTable - Sample1"),'<center>';
print TEST1 $table1->startTable;
print TEST1 $table1->tr_TH({bgcolor=>'#996666'},
        'Col1','Col2','Col3','Col4','Col5','Col6');

my @ary1 = ('Cell 1', 'Cell 2');
my @ary2 = ('Cell 3', 'Cell 4');
my @ary3 = ('Cell', 6);
print TEST1 $table1->tr_TD({align=>'center'}, 
           @ary1, @ary2, ['Cell', 5],\@ary3);
 print TEST1 $table1->endTable,'</center>',end_html;
 close TEST1 or croak "Cant close test file: $!";
}
############################ 2
{
open(TEST2,'>','examples/Sample2.htm') or croak "Cant open test file: $!";
 my $table2 = HTML::EasyTable->new(
                -mass_param=>{-width_6=>75,
                              -bgcolor_6=>'#6666FF',
                              -style_6=>'font-weight:600;'},
                -style=>'border: 2px black double;',
                -border=>1,
                -cellpadding=>2,
                -cellspacing=>0
               );
 sub digit {
     int(rand 400);
 }
 print TEST2 start_html("HTML::EasyTable - Sample2"),'<center>';
 print TEST2 $table2->startTable;
 print TEST2 $table2->tr_TH(
              {
               tr_align=>'center',
               tr_style=>'font-weight:600;
                          background-color:#6699FF;'
              },
         'Num 1','Num 2','Num 3','Num 4','Num 5','Total');

 my ($c1,$c2,$c3,$c4,$c5);
 for (my $i=10; $i>=0;$i--) {
     print TEST2 $table2->tr_TD({tr_align=>'center'},
      $c1=digit(), $c2=digit(), $c3=digit(), 
      $c4=digit(), $c5=digit(),$c1+$c2+$c3+$c4+$c5);
 }
 print TEST2 $table2->endTable,'</center>',end_html;
 close TEST2 or croak "Cant close test file: $!";
}
############################ 3
{
open(TEST3,'>','examples/Sample3.htm') or croak "Cant open test file: $!";
my $table3 = HTML::EasyTable->new(
                -mass_param=>{-width_1=>25},
                -width=>'100%'
               );
 my %tr_options = (
       tr_align=>'center',
       tr_style=>'background-color: #990000;
                  color:white;cursor:help;
                  font-family: verdana,arial;font-weight:600;'
     );  

print TEST3 start_html("HTML::EasyTable - Sample3");
print TEST3 $table3->startTable;
my $r = 255;
my $x = "A";
my $y = 0;
my $i = 1;
while ($i <= 285) {
  my $letter = "A";
  $tr_options{-style_1} = 
         "background-color:rgb($i,$i,$i);
          color:rgb($r,$r,$r);";
  $i+=30; $r-=24;
  my @text;
  $text[0..1] = $x++;
  $text[0] = $y++;
  $tr_options{"-style_".$y} = 
         "background-color:rgb($i,$i,$i);
          color:rgb($r,$r,$r);";
  for (1..$#text-1) {
    $text[$_]= ($y-1).$letter++;
    $tr_options{"-title_".($_+1)} = "Cell $text[$_]";
  }
  print TEST3 $table3->tr_TD(\%tr_options, @text);     
}
print TEST3 $table3->endTable,end_html;
close TEST3 or croak "Cant close test file: $!";
}
#########################################################
{
open(TEST4,'>','examples/Sample4.htm') or carp "Cant open test file: $!";
my $table4 = HTML::EasyTable->new(
              -border=>'1',
              -width=>'100%',
              -cellcpasing=>'0'
              );

my %tr_options = (
      tr_align=>'center',
      tr_style=>'font-family: verdana,arial;font-weight:600;'
    );

print TEST4 start_html("HTML::EasyTable - Sample4");
print TEST4 $table4->startTable;
my ($i,$j,$k);
my @hex = ('00','33','66','99','CC','FF');
for ($i = 5; $i >= 0; $i--) {
    for ($j = 5; $j >= 0; $j--) {
        my $cell=1;
        my @colors;
        for ($k= 5; $k >= 0; $k--) {
            $tr_options{"-style_$cell"} ="background: $hex[$i]$hex[$j]$hex[$k];";
            $tr_options{"-style_$cell"} .="color: $hex[$j-1]$hex[$k-1]$hex[$j-1];";
            $colors[$cell-1] = '#'.$hex[$i] . $hex[$j] . $hex[$k];
            $cell++;
        }
        print TEST3 $table4->tr_TD(\%tr_options,@colors);
    }
}
print TEST4 $table4->endTable,end_html;
close TEST4 or carp "Cant close test file: $!";
}
my $all_ok;
ok(-e 'examples/Sample1.htm', "=> examples/Sample1.htm") && $all_ok++;
ok(-e 'examples/Sample2.htm', "=> examples/Sample2.htm") && $all_ok++;
ok(-e 'examples/Sample3.htm', "=> examples/Sample3.htm") && $all_ok++;
ok(-e 'examples/Sample4.htm', "=> examples/Sample4.htm") && $all_ok++;
print '='x45,"\nCongratulations. All tests are passed.\n",
"You should view results in directory 'examples'\n",
"="x45,"\n" if $all_ok == 4;
#########################

