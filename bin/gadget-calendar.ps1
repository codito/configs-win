  #---8<---gadget-calendar.ps1---Jean-JMST-Belgium---8<---
  
   #=9/2006===================================Version 1.3===#
   #===========  "human readable" grid calendar ============#
   #
   # To test :
   #
   #  .\gadget-calendar
   #   °shows month calendar with current day
   #    highlighted (red on white by default)
   #  .\gadget-calendar 6/2006|tee -file calendar.txt
   #  .\gadget-calendar "6/2006"|tee -file calendar.txt
   #  .\gadget-calendar "june 2006"|tee -file calendar.txt
   #  .\gadget-calendar "juin 2006"|tee -file calendar.txt
   #   °outputs june 2006 month grid and writes it
   #    to calendar.txt file
   #  .\gadget-calendar 2006|tee -file calendar.txt
   #   °outputs full year 2006 grid (3 x 4) and writes it
   #    to calendar.txt file
   #
   # NOTES
   #
   #  About 1st century :
   #
   #   When a string is passed for first argument, years between
   #   1 and 99 must be 0000 formated (so 0001 to 0099).
   #    .\gadget-calendar "5/0023"
   #
   #  Values allowed for years :
   #
   #   As in .Net specifications years can be in range 1..9999
   #
   # THANKS :
   #
   #  to MOW to have fix a previous ennoying bug "current
   #  day not always highlighted".
   #  See this message on microsoft.public.windows.powershell :
   #   Ozb94fPnGHA.4240@TK2MSFTNGP02.phx.gbl
   #
   #  to James Truher to have fix a RC1-RC2 compatibility issue.
   #  See this message on microsoft.public.windows.powershell :
   #   OZZcK3P4GHA.2208@TK2MSFTNGP04.phx.gbl
   #
   #  to Marco Shaw to have pointed me a bug with dates not
   #  "French formatted" to render full year calendar :
   #    by mail
   #   
   #========Tested on PowerShell Version 1======================#
  
   param(
         $vardate=(get-date).Date,
         [ConsoleColor]$calendarbg="Black",
         [ConsoleColor]$monthyearfg="Cyan",
         [ConsoleColor]$daynamefg="Red",
         [ConsoleColor]$dayfg="White",
         [ConsoleColor]$highlightdayfg="Red",
         [ConsoleColor]$highlightdaybg="White"
        )

    ## Sets $OFS to a space char for script scope ##
   $script:OFS=" "
   
   #### Build an array of two first letters ####
   #### localized days names                ####
   
   $firstdate=[datetime](0)
   $daysnames=(0..6)|%{
     ($_=$firstdate.ToString("dddd").SubString(0,2))
     $firstdate=$firstdate.AddDays(1)
    }

   function build_date_table($date){
    #### Returns an array containing days numbers ####
    #### and month name                           ####
  
     ## Sets variables containing month and year of the date ##
    $m=$date.Month
    $y=($date.Year).ToString("0000")
     ## Get month"s first day position in the week ##
    [datetime]$firstday=[string]$m+"/"+[string]$y
    $fd=[int]$firstday.DayOfWeek
     ## As "dayofweek" is 0 indexed from Sunday to    ## 
     ## Saturday and we want from Monday to Sunday we ##
     ## use a "1 indexed" concept :                   ##

    if($fd -eq 0){$fd=7}
     ## Sets a variable containing the number ##
     ## of days in the month                  ##
    $ld=(Get-Culture).Calendar.GetDaysInMonth($y,$m)
     ## Build an array containing days numbers relative ## 
     ## to days names positions.                        ##
     ## If a position is not used, the value is set to  ##
     ## a space char.                                   ##
    $table=@()
   
    for($i=0;$i -lt $fd-1+$ld;$i++){
     if($i+1 -lt $fd)
      {$table+=" "*2}
     else
      {$table+=[string]($i-$fd+2)}
     if($table[$table.Length-1].Length -eq 1)
      {$table[$table.Length-1]+=" "}
     if(($i+1) % 7 -eq 0)
      {
       $table[$table.Length-1]+=" "
       if(!($table[$table.Length-1].Trim() -eq $ld))
        {$table[$table.Length-1]+="`n"}
      }
    }
     ## Adds some extra space chars needed for formating output##
    for($i=0;$i -lt $table.Length % 7)
     {$table+=" "*2}
    if($table[$table.Length-1] -eq " "*2)
     {$table[$table.Length-1]+=" "}
     ## get Month/Year localized string ##
    $monthyear=$date.ToString("MMMM  yyyy")
    $monthyear=(" "*((21-$monthyear.Length)/2))+$monthyear
    $monthyear+=(" "*(21-$monthyear.Length))+" "
    return $table,$monthyear
   }#end function build_date_table
  
   #### Writes + colorizes calendar grid #### 
  
    ## Set console's colors for Month/Year line and grid ## 
    [console]::BackgroundColor=$calendarbg
    ## If an integer is passed for $vardate then defines ##
    ## $fullyear to $vardate                             ##
   if($vardate.GetTypeCode() -eq "Int32"){$fullyear=$vardate.ToString("0000")}
   
   if(!$fullyear){
    $monthtable=build_date_table(get-date $vardate)
    $monthyear=$monthtable[1]
    $daystable=$monthtable[0]
    [console]::ForegroundColor=$monthyearfg
     ## Ouputs month/year line ##
    [string]$monthyear
     ## Set days names line foreground color ##
    [console]::ForegroundColor=$daynamefg
     ## Outputs day names ##
    " "+[string]$daysnames+" "
     ## Set days numbers foreground color ##
    [console]::ForegroundColor=$dayfg
    if($vardate -ne (get-date).Date)
     ## Outputs calendar month grid ##
     {(" "+([string]($daystable))).Split("`n")|%{$_}}
    else
     ## Shows current month grid and highlight current day ##
     {
      ($daystable)|`
       %{
         write-host (" ") -NoNewLine
         if($_.Trim() -eq (get-date $vardate).Day)
          {
           write-host ($_[0]+$_[1]) `
            -NoNewLine `
            -ForegroundColor $highlightdayfg `
            -BackgroundColor $highlightdaybg
           if($_[2] -eq " "){write-host($_[2])}
          }
         else
          {write-host ($_) -NoNewLine}
        }
      write-host "`r"
     }
    }else{
     ## Outputs full year grid ##
     $yeartable=(0..11)
     $year=$fullyear
     $monthnames=@()
     for($i=1;$i -lt 13;$i++){
      $monthdays=
      build_date_table(get-date -month $i -year $year)
      $yeartable[$i-1]=
       ((" "+[string]($monthdays)[0]).Split("`n"))
      $monthnames+=($monthdays[1])
     }
     for($i=0;$i -lt 12;$i+=3){
      [console]::ForegroundColor=$monthyearfg
      $monthnames[$i]+$monthnames[$i+1]+$monthnames[$i+2]
      [console]::ForegroundColor=$daynamefg
      ((" "+[string]$daysnames+" ")*3)
      $max=(
            (
             $yeartable[$i].length,`
             $yeartable[$i+1].length,`
             $yeartable[$i+2].length
            )|sort
           )[2]
      for($j=0;$j -lt 3;$j++){
        if($yeartable[$i+$j].Length -lt $max)
         {$yeartable[$i+$j]+=" "*22}
      }
      [console]::ForegroundColor=$dayfg
      for($j=0;$j -lt $max;$j++)
       {
        (
         $yeartable[$i][$j]+
         $yeartable[$i+1][$j]+
         $yeartable[$i+2][$j]
        )
       }
      "" 
     }
    }
    ## Restores console's background/foreground colors ##
   [console]::ResetColor()
  #---8<---gadget-calendar.ps1---Jean-JMST-Belgium---8<---
