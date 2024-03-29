package HTML::EasyTable;
use strict; 
use Carp;
use warnings;
BEGIN {
        use Exporter   ();
        our ($VERSION, @ISA);
        $VERSION     = '0.04';
        @ISA         = qw(Exporter);
}

#
# All documentation in POD format is at the end of file
#

sub new {
        my $this = shift;
        my $self = {};
        my $class = ref($this) || $this;
        %{$self} = ref($_[0])? %{$_[0]} :  @_;
        bless $self,$class;
        return $self;
}

sub startTable {
        my $self = shift;
        my @options;
        $options[0] = "\n<table";
        while (my ($k,$v) = each %{$self}) {
        next if $k eq lc '-mass_param';
        ($k) = $k =~ /^\-(\S+)$/ if $k =~ /^\-(\S+)$/;
                $options[$#options+1] = "$k=\"".$v.'"';
        }
        $options[$#options+1] = '>';
        return join ' ',@options;
}

sub tr_TD {
        my $self = shift;
        my %mass_param;
        if ($self->{-mass_param}) {
                %mass_param = %{$self->{-mass_param}};
                while (my ($k,$v) = each %mass_param) {
                        my @k = split /_/,$k ||
                        croak "Parameter ->$k<- is invalid.\nHe must ending with digit.".
                                  "The digit tell to the module for who cell is this parameter \n->$!<-";
                        $k = lc $k[0];
                        $k =~ s/^-//;
                        $k[1] = lc $k[1];
                        $v = lc $v;
                        $mass_param{$k[1]} .= " $k\=\"$v\"";
                }
        }
        my (@data,@result);
        (@data = @_) || ($data[0] = '&nbsp;');
        my $TR="";
        if (ref($data[0]) && (ref($data[0]) eq 'HASH')) {
                while (my ($k,$v) = each %{$data[0]}) {
                        if ($k =~ /\-(\S+)_(\d+)/) {
                           $result[$2-1]{$1}=$v;
                        } elsif ($k =~ /^(\w+)/) {
                                $TR .= " $1=\"$v\"";
                        } else {
                                croak "Parameter $k is invalid.He must begin with '-' for cell ".
                                  "or without '-' for <TR> parameter.";
                        }
                }
                shift @data;
                my @return;
                my $i=-1;
                for (@result) {
                        ++$i;
                        while (my ($k,$v)= each %{$_}) {
                                $k = lc $k;
                                $return[$i] .= " $k=\"$v\"";
                        }
                }
                @result=();
                $#result = $#data;
                for (0..$#result) {
                    my @cell = ref($data[$_])? @{$data[$_]}:$data[$_];
                    if ($mass_param{$_+1}) {
                            $return[$_] .= $mass_param{$_+1};
                    }
                    if ($return[$_]) {
                            $result[$_] = "\n\t<td$return[$_]>@{cell}</td>";
                    } else {
                            $result[$_] = "\n\t<td>@{cell}</td>";
                    }
                }
        } else {            
            for (0 .. $#data) {
				my @cell = ref($data[$_])? @{$data[$_]}:$data[$_];
                $result[$_] = "\n\t<td>@{cell}</td>";
            }
        }
        $TR ||= "";
        $TR = '<tr' . $TR . '>';
        push @result,"\n    <\/tr>"; unshift @result,"\n    $TR";
        return @result;
}

sub tr_TH {
        my $self = shift;
        my (@data,@result);
        (@data = @_) || ($data[0] = '&nbsp;');
        my $TR="";
        if (ref($data[0]) && (ref($data[0]) eq 'HASH')) {
                while (my ($k,$v) = each %{$data[0]}) {
                        if ($k =~ /\-(\S+)_(\d+)/) {
                           $result[$2-1]{$1}=$v;
                        } elsif ($k =~ /^(\w+)/) {
                                $TR .= " $1=\"$v\"";
                        } else {
                                croak "Parameter $k is invalid.He must begin with '-' for cell ".
                                  "or without '-' for <TR> parameter.";
                        }
                }
                shift @data;
                my @return;
                my $i=-1;
                for (@result) {
                        ++$i;
                        while (my ($k,$v)= each %{$_}) {
                                $k = lc $k;
                                $return[$i] .= " $k=\"$v\"";
                        }
                }
                @result=();
                $#result = $#data;
                for (0..$#result) {
                    my @cell = ref($data[$_])? @{$data[$_]}:$data[$_];
                    if ($return[$_]) {
                            $result[$_] = "\n\t<th$return[$_]>@{cell}</th>";
                    } else {
                            $result[$_] = "\n\t<th>@{cell}</th>";
                    }
                }
        } else {            
            for (0 .. $#data) {
				my @cell = ref($data[$_])? @{$data[$_]}:$data[$_];
                $result[$_] = "\n\t<th>@{cell}</th>";
            }
        }
        $TR ||= "";
        $TR = '<tr' . $TR . '>';
        push @result,"\n    <\/tr>"; unshift @result,"\n    $TR";
        return @result;
}

sub endTable {
        return "\n<\/table>\n";
}

1;

__END__

=head1 NAME

HTML::EasyTable - a Module for easy printing of HTML Tables

=head1 SYNOPSIS

 use HTML::EasyTable;
 my %options = (
    -mass_param=>{
            -style_3=>'font-weight:600;', # apply to column 3
            -title_4=>'Click here!'       # apply to column 4
    },
    -style=>'width:800;',     #
    -id=>'table1',            #
    -border=>1,               #  Any standart
    -bordercolor=>'#000099',  #  <table> options
    -cellspacing=>'0'         #
 );
 # Construct $table object with %options arguments:
 my $table = HTML::EasyTable->new(\%options);

 # print <table style="width:800;" id="table1" .... without mass_param :
 print $table->startTable;

 # print <tr> and table cells with
 # options below plus "mass_param":
 print $table->tr_TD(
         {-bgcolor_3=>'#339933',               # Cell 3 bgcolor
          -title_3=>'Click here',              # title of Cell 3
          align=>'center',                  # <tr align="center"
          style=>'font-weight:600;'         # <tr style="font-weight:600;"
         },       
         'Cell 1',$cell_2,'Cell 3',\@cell_4    # content of <td> cells
       ); 
 print $table->tr_TH(....);                    # content of <th> cells
 print $table->endTable;                       # this just print </table>

=head1 DESCRIPTION

This module print HTML tables very easy and simple. 

=head2 METHODS

=over 5

=item *
B<new(-mass_param=E<gt>{\%mass_opts},\%opts);>

 Create object HTML::EasyTable with various options :

I<%opts>  arguments whos may be any standard <table>      
 arguments in CGI.pm like style:
 -border=>'1',-bgcolor=>'#ffffff'...etc.E<nbsp>E<nbsp>E<nbsp>E<nbsp>E<nbsp>E<nbsp>E<nbsp>
I<-mass_param>   set arguments on columns:
 -mass_param=>{-title_3=>'This is Cell 3 TITLE',
               -style_4=>'cursor:help;'}
 This will make all third cells with title 
 "This is Cell 3 TITLE" and all fourth cells with
 argument: style="cursor:help;"

=item *
B<startTable>

 This is complete <table> TAG with all arguments in B<new()>,
 but without  B<-mass_param> option:
 print $table->startTable;
 # This print <table border="1" bgcolor="#ffffff">

=item *
B<tr_TD({\%opts},LIST);>

Where LIST is list of cells.
Contain one table line: <tr><td></td></tr> with specifed options.

=item *
B<tr_TH({\%opts},LIST);>

Where LIST is list of cells.
Contain one table line with heading cells: <tr><th></th></tr>

Option B<-mass_param> has no influence in this method!

=back

For more info see B<EXAMPLES> below.

=head2 SYNTAX

All arguments and options is given as hashref
{key=>'value',key2=>value2} or {\%hashref} 

All cell content is given thereby:
 tr_TD/TH({\%opts},'blabla','blabla')
   or
 tr_TD/TH({\%opts},@array)

Z<> Or use mixed list instead @array like: 
  ('bla bla',        # Cell-1 string
   $cell2,           # Cell-2 scalar
   @cells_3_and_4,   # Cell-3 & Cell-4 array
   ['cell', 5],      # Cell-5 anonynous array
   \@cell_6          # Cell-6 arrayref
  );

Z<>B<Enjoy!>

=over 4

=item new()

-mass_param=>{} - argument for one column who take
 anonymous hash with arguments: -bgcolor_3,-style_2... 
 where numbers 3 and 2 are columns (or every third and second cells).

Other arguments are for <table> tag in format new(key=>'value',key2=>value2);

=item tr_TD()/tr_TH() - these similar methods have two different type arguments:

 1) ARGUMENT  - refer to <tr> tag.Example align,style ..etc
 2) -ARGUMENT_CELL  - put into CELL argument ARGUMENT
 such as in "mass_param".Example -width_1=>"40",-width_2=>"20"
 what prints <td width="40"></td><td width="20"></td>

Note that B<ARGUMENT> option NOT have prefix '-'(minus).
This is important!!

=back

=head2 EXPORT

None by default.

=head1 EXAMPLES

These examples should be seen in directory "examples"
after "make test" create her
 # Very simple exaple with mixed type cells
 # See: B<examples/HTML-HTML::EasyTable-Sample1.htm>
 use HTML::EasyTable;
 use CGI qw(:standard);
 my $table = HTML::EasyTable->new(
                -style=>'border: 2px black double;',
                -border=>1,
                -cellpadding=>2,
                -cellspacing=>0
               );
 print header,start_html,'<center>';
 print $table->startTable;
 print $table->tr_TH({bgcolor=>'#996666'},
        'Col1','Col2','Col3','Col4','Col5','Col6');

 my @ary1 = ('Cell 1', 'Cell 2');
 my @ary2 = ('Cell 3', 'Cell 4');
 my @ary3 = ('Cell', 6);
 print $table->tr_TD({align=>'center'}, 
           @ary1, @ary2, ['Cell', 5],\@ary3);

 print $table->endTable,'</center>';


# Here is a simple Random Calculator:
 # See: B<examples/HTML-HTML::EasyTable-Sample2.htm>
 use HTML::EasyTable;
 use CGI qw(:standard);
 my $table = HTML::EasyTable->new(
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
 print header,start_html,'<center>';
 print $table->startTable;
 print $table->tr_TH({bgcolor=>'#6699FF'},
         'Num 1','Num 2','Num 3','Num 4','Num 5','Total');

 my ($c1,$c2,$c3,$c4,$c5);
 for (my $i=10; $i>=0;$i--) {
     print $table->tr_TD({align=>'center'},
      $c1=digit(), $c2=digit(), $c3=digit(), 
      $c4=digit(), $c5=digit(),$c1+$c2+$c3+$c4+$c5);
 }
 print $table->endTable,'</center>';

Z<>=======================================================================
 # Example 2
 # See: B<examples/HTML-HTML::EasyTable-Sample2.htm>
 use HTML::EasyTable;
 use CGI qw(:standard);

 my $table = HTML::EasyTable->new(
                -mass_param=>{-width_1=>25},
                -width=>'100%'
               );
 my %tr_options = (
       align=>'center',
       style=>'background-color: #990000;
               color:white;cursor:help;
               font-family: verdana,arial;font-weight:600;'
     );  

print header,start_html;
 print $table->startTable;
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
        $tr_options{"-title_".($_+1)} S<= "Cell $text[$_]";>
      }
      print $table->tr_TD(\%tr_options, @text);     
 }
 print $table->endTable;

E<nbsp>=======================================================================
 # Print table 36 x 6 cells with colors in HEX format
 # See: B<examples/HTML-HTML::EasyTable-Sample3.htm>
Z<>
    use HTML::EasyTable;
    use CGI qw(:standard);
    my $table = HTML::EasyTable->new(
                  -border=>'1',
                  -width=>'100%',
                  -cellcpasing=>'0'
                  );

    my %tr_options = (
          align=>'center',
          style=>'font-family: verdana,arial;font-weight:600;'
        );

    print header,start_html;
    print $table->startTable;
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
            print $table->tr_TD(\%tr_options,@colors);
        }
    }
    print $table->endTable;


=head1 SEE ALSO

B<CGI>

=head1 BUGS

B<When set:>
 HTML::EasyTable->new(-mass_param=>{-title_3=>'This is cell 3'});

B<then set:>
 print $table->tr_TD({-title_3=>'Another title'},
                   'cell 1','cell 2','cell 3'
                 );

B<This print:>

<table>
  <tr>
    <td>cell 1</td>
    <td>cell 2</td>
    <td B<title="Another title" title="this is cell 3">>
       cell 3
    </td>
  </tr>
</table>

If You found other bugs Please report them.

=head1 AUTHOR

Angel N. Kolev, E<lt>meneldor@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by Angel N. Kolev

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
