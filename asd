elif(matched.begins_with("question ")): # WE ARE DOING A QUESTION, BIG THINGS COMING
				#q1|q2|q3[a1|a2|a3]
				# strip off the question  first so that the lenght and index is right
				var striped = matched.lstrip("question ")
				# strip off the answers and split the questions into an array of 3
				var quests = striped.substr(0, striped.length()-striped.find("{")).split("|", true, 3)
				# strip off questions and split anwsers into an array
				var ans = striped.substr(striped.find("{")+1).rstrip("}").split("|", true, 3)
				var questBoxes = []
				
				for quest in quests:
					var box = DialogueBox.new()
					box.dialogueText = quest
					box.formatText()
					questBoxes.append(box)
				for fart in questBoxes:
					print(fart.dialogueText)
