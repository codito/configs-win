# Functions for PS
# Last Modified: 14/11/2012,  India Standard Time

# Search utilities
function global:rgrep { ls -recurse -include $args[1] | grep $args[0] }
function global:rfind { ls -recurse -include $args[0] | % { $_.FullName } }

# File system utilities
function global:mklink { cmd /c mklink $args }
function global:ddiff($dir1, $dir2, $filePattern)
{
    $a = (ls $dir1 -recurse -include $filePattern)
    $b = (ls $dir2 -recurse -include $filePattern)
    $len = $a.Length

    $cnt = 0
    while ($cnt -lt $len)
    {
        fdiff $a[$cnt] $b[$cnt]
        $cnt++
    }
}

function global:fdiff($file1, $file2)
{
    $left = (cat $file1)
    $right = (cat $file2)

    write-host "Comparing $file1 : $file2"
    diff $left $right
}

# Diffs multiple files in a directory selected by a pattern
# Incomplete
function global:mdiff($dir, $pattern)
{
    $fileContentHash = @{}
    $maxLines = 0

    # read all the files
    ls $dir -recurse -include $pattern |
    % {
        $fileName = $_
        $fContent = (cat $FileName)

        # create line wise hash which will contain the file and the line numbers
        # @{ Line1 = { file:line1; file2:line1; file3:line1 .. } }
        $lineCount = 1
        $fContent |
        % {
            $fileAndLine = $fileName+":"+$_
            $currentValue += ,$fileAndLine
            if ($fileContentHash.ContainsKey($lineCount))
            {
                # the key exists, so add the file:line to the value
                $currentValue = $fileContentHash.Item($lineCount)
                $currentValue += ,$fileAndLine
                $fileContentHash.Item($lineCount) = $currentValue
            }
            else
            {
                # add a key/value for this line number
                $fileContentHash.Add($lineCount, $currentValue)
            }

            $currentValue = $null
            $lineCount++
        }

        write-host "Parsed: $fileName"
    }

    # traverse through the hash and list the differences
    $fileContentHash
}
