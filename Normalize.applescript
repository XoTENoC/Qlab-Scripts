set theReferenceLevel to -24 --set desired LUFS level
set thefaderLevel to 0 --set the master fader level for your preferred output level for cues with an LUFS at the reference level
set currentTIDs to AppleScript's text item delimiters
tell application id "com.figure53.QLab.4" to tell front workspace
	display dialog "WARNING: This will change the master levels of all selected cues" & return & return & "A dialog will signal when the level setting is complete." & return & return & "PROCEED?"
	try
		set theselected to the selected as list
		if (count of items of theselected) > 0 then
			repeat with eachcue in theselected
				if q type of eachcue is "audio" then
					set currentFileTarget to quoted form of POSIX path of (file target of eachcue as alias)
					set theLUFS to (do shell script "/usr/local/bin/r128x-cli" & " " & currentFileTarget as string)
					--parse theLUFS to extract the actual LUFS from a very long string
					--replace every occurrence of "+" with "plus"
					set AppleScript's text item delimiters to "+"
					set the item_list to every text item of theLUFS
					set AppleScript's text item delimiters to "plus"
					set theLUFS to the item_list as string
					--replace every occurrence of "-" with "minus"
					set AppleScript's text item delimiters to "-"
					set the item_list to every text item of theLUFS
					set AppleScript's text item delimiters to "minus"
					set theLUFS to the item_list as string
					set AppleScript's text item delimiters to currentTIDs
					--get the third word from the end
					set the theLUFS to word -3 of theLUFS
					--replace the string "minus" in theLUFS with "-"
					if character 1 of theLUFS = "m" then
						set theLUFS to "-" & characters 6 thru -1 of theLUFS
					else
						--replace the string "plus" in theLUFS with "+"
						set theLUFS to "+" & characters 5 thru -1 of theLUFS
					end if
					set theadjustment to (theReferenceLevel - theLUFS) + thefaderLevel
					set the notes of eachcue to theLUFS & " " & theadjustment
					eachcue setLevel row 0 column 0 db theadjustment
				end if
			end repeat
			display dialog "Level Setting Complete" buttons "OK" default button "OK"
		end if
	end try
end tell