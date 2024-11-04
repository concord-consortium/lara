#### Start creation of one activity ####
# Create the activity
act = LightweightActivity.create!(name: "Test activity")

act.related = "<p>Here are some related links:</p><ul><li><a href='http://google.com'>Google</a></li><li><a href='https://github.com/concord-consortium/lightweight-activities-plugin'>Github repository</a></li></ul>"
act.save

### Page 1 ###
# This creates a page and adds it to the activity.
page1 = act.pages.create!(name: "Page 1", text: "This is the main activity text.")
# Creates an interactive
interactive_p1 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/embeddable.html#interactives/samples/1-oil-and-water-shake.json")
# Adds the interactive to the page.
page1.add_interactive(interactive_p1)

## Add embeddables ##
# Create two OpenResponse embeddables
or1 = Embeddable::OpenResponse.create!(name: "Open Response 1", prompt: "Why do you think this model is cool?")
or2 = Embeddable::OpenResponse.create!(name: "Open Response 2", prompt: "What would you add to it?")

# Create one MultipleChoice embeddable, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "What color is chlorophyll?")
Embeddable::MultipleChoiceChoice.create(choice: 'Red', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'Green', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'Blue', multiple_choice: mc1)

# Create another MultipleChoice embeddable, with choices
mc2 = Embeddable::MultipleChoice.create!(name: "Multiple choice 2", prompt: "How many protons does Helium have?")
Embeddable::MultipleChoiceChoice.create(choice: '1', multiple_choice: mc2)
Embeddable::MultipleChoiceChoice.create(choice: '2', multiple_choice: mc2)
Embeddable::MultipleChoiceChoice.create(choice: '4', multiple_choice: mc2)
Embeddable::MultipleChoiceChoice.create(choice: '7', multiple_choice: mc2)

# Create an (X)HTML embeddable
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "This is some <strong>xhtml</strong> content!")

# Add the five embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page1.add_embeddable(mc1, 1)
page1.add_embeddable(or1, 2)
page1.add_embeddable(xhtml1, 3)
page1.add_embeddable(or2, 4)
page1.add_embeddable(mc2, 5)

page1.sidebar = "<p>This is first-page sidebar text. Only the first page has sidebar text.</p>"
page1.save
### End Page 1 ###

### page 2 ###
# This creates a page and adds it to the activity.
page2 = act.pages.create!(name: "Page 2", text: "This is the main activity text. Sometimes, it just needs to be a bit longer.")
# Create another interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_p2 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/embeddable.html#interactives/samples/1-oil-and-water-shake.json")
# Add the same interactive to the page.
page2.add_interactive(interactive_p2)

## Add embeddables ##
# Create an OpenResponse embeddable
or3 = Embeddable::OpenResponse.create!(name: "Open Response 1", prompt: "What does the model shown represent?")

# Create a MultipleChoice embeddable, with three choices
mc3 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Why are some of the circles red?")
Embeddable::MultipleChoiceChoice.create(choice: 'Red is a pretty color', multiple_choice: mc3)
Embeddable::MultipleChoiceChoice.create(choice: 'Because they are dangerous', multiple_choice: mc3)
Embeddable::MultipleChoiceChoice.create(choice: 'Because they are angry', multiple_choice: mc3)

# Create an (X)HTML embeddable.
xhtml2 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "This is some <strong>xhtml</strong> content!")

# Add the three embeddables to the page, in order.
page2.add_embeddable(xhtml2, 1)
page2.add_embeddable(mc3, 2)
page2.add_embeddable(or3, 3)
### End Page 2 ###

### page 3 ###
# This creates a page and adds it to the activity.
page3 = act.pages.create!(name: "Page 3", text: "This is the last page of the activity! I hope you've enjoyed your time today.")
# Create another interactive to add to this page.
interactive_p3 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/embeddable.html#interactives/samples/1-oil-and-water-shake.json")
page3.add_interactive(interactive_p3)

## Add embeddables ##
# Create an OpenResponse embeddable
or4 = Embeddable::OpenResponse.create!(name: "Open Response 1", prompt: "What did you think of this activity?")

# Create three (X)HTML embeddables
xhtml3 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "I love adding text to these things.")
xhtml4 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "It's so much fun!")
xhtml5 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "Good job! You're all done now.")

# Add the four embeddables to the page, in order.
page3.add_embeddable(xhtml3, 1)
page3.add_embeddable(xhtml4, 2)
page3.add_embeddable(or4, 3)
page3.add_embeddable(xhtml5, 4)
### End Page 3 ###

#### End Activity Creation ####

#### Start creation of one activity ####
# Create the activity
act_boiling_point = LightweightActivity.create!(name: "Intermolecular Attractions and Boiling Point ")

act_boiling_point.related = "<p>Here are some related links:</p><ul><li><a href='http://concord.org'>The Concord Consortium</a></li><li><a href='http://nsf.gov'>National Science Foundation</a></li></ul>"
act_boiling_point.save

### Page 1 ###
# This creates a page and adds it to the activity.
page_1_boiling_point = act_boiling_point.pages.create!(name: "Page 1", text: "All molecules attract to each other through forces called \"intermolecular attractions.\" The temperature at which many substances boil is determined by intermolecular attractions.")

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>In this activity you will explore how molecular level attractions affect a substance's boiling point.</p><p><strong>Molecules can be either polar or nonpolar</strong></p><ul><li>polar molecules share electrons evenly</li><li>non-polar molecules don't share electrons evenly, causing the formation of partial positive and partial negative charges on the surface of the molecule)</li></ul><p>All molecules, polar and non-polar, have an attraction for other molecules via the Coulomb force&#8212;the attractive force between positive and negative charges.</p><p>So, how do non-polar molecules form attractions if there is no apparent surface charge?</p><p><a href=\"http://chemsite.lsrhs.net/FlashMedia/html/dipoleVsLondon.html\">http://chemsite.lsrhs.net/FlashMedia/html/dipoleVsLondon.html</a></p><p>Over time, the fluctuating instantaneous dipoles will average out so that non-polar molecules have no permanent dipoles.  The average attraction between non-polar molecules will be weak compared to similarly sized polar molecules.</p><p>Polar molecules have a permanent dipole so that uneven charge distribution is reflected over time as well, and the permanent attraction is stronger than in non-polar molecules.</p>")

# Create an OpenResponse embeddable
or1 = Embeddable::OpenResponse.create!(name: "Open Response One", prompt: "How, other than color, are polar and non-polar molecules different?")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page_1_boiling_point.add_embeddable(xhtml1, 1)
page_1_boiling_point.add_embeddable(or1, 2)
page_1_boiling_point.sidebar = "<p><img src=\"/assets/lightweight/boiling-point-sidebar2.jpg\" alt=\"Nitrogen Ice Cream\" />At the molecular level, boiling looks similar for all materials.  At the macroscopic level, boiling can feel very different.</p><p>Compare the boiling of a pot of water with the boiling of nitrogen gas.</p><p>In the kitchen, you might boil water to cook pasta, but in the image above, MIT students are using boiling liquid nitrogen to make ice cream.</p><p>Water boils at 100&deg;C, while nitrogen boils at -196&deg;C. Why the big difference? That has to do with intermolecular attractions!</p>"
page_1_boiling_point.save
### End Page 1 ###

## Page 2 ###
# This creates a page and adds it to the activity.
page_2_boiling_point = act_boiling_point.pages.create!(name: "Page 2", text: "All molecules attract to each other, but there are different patterns and strengths of attraction. The model shows a bunch of polar and non-polar molecules.")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_pn2 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/sam/intermolecular-attractions/1-introduction.json")
# Add the same interactive to the page.
page_2_boiling_point.add_interactive(interactive_pn2)

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>Explore how molecules form intermolecular attractions when they are close together. Try combinations of different and similar molecules.</p>")

# Create one MultipleChoice embeddable, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Which molecules were attracted to each other?")
Embeddable::MultipleChoiceChoice.create(choice: 'non-polar molecules were attracted to non-polar molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'non-polar molecules were attracted to polar molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'the positive parts of polar molecules were attracted', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'the negative parts of polar molecules were attracted', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'the positive parts of polar molecules were attracted to negative parts of polar molecules', multiple_choice: mc1)

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page_2_boiling_point.add_embeddable(xhtml1, 1)
page_2_boiling_point.add_embeddable(mc1, 2)
### End Page 2 ###

## Page 3 ###
# This creates a page and adds it to the activity.
page_3_boiling_point = act_boiling_point.pages.create!(name: "Page 3", text: "")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_pn3 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/sam/intermolecular-attractions/2-comparing-dipole-dipole-to-london-dispersion.json")
# Add the same interactive to the page.
page_3_boiling_point.add_interactive(interactive_pn3)

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>There are two categories of intermolecular attractions:</p><ul><li>Dipole-dipole = the attractive force between polar molecules</li><li>London dispersion = the attractive force between non-polar molecules</li></ul><p>There is a weak attraction between all atoms and molecules called London dispersion.</p><p>(If an atom is partially charged because it is part of a polar molecule or fully charged because it is part of an ionic compound, then similar charges will actually repel, overcoming the weak London dispersion attraction.)</p><p>Polar molecules also attract each other through dipole-dipole attractions. Together, the London dispersion and dipole-dipole attractions make up what we call intermolecular attractions.</p><p>In the previous model, time was stopped so that you could explore when intermolecular attractions form. In this model, the molecules will be allowed to \"feel\" those attractions and move accordingly.</p><p>Use the model below to explore the differences in strength of London dispersion and dipole-dipole attractions for molecules of similar size.</p>")

# Create three MultipleChoice embeddables, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "What is the primary attraction between two non-polar molecules?")
Embeddable::MultipleChoiceChoice.create(choice: 'London dispersion attraction', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'dipole-dipole attraction', multiple_choice: mc1)

mc2 = Embeddable::MultipleChoice.create!(name: "Multiple choice 2", prompt: "What is the primary attraction between two polar molecules?")
Embeddable::MultipleChoiceChoice.create(choice: 'London dispersion attraction', multiple_choice: mc2)
Embeddable::MultipleChoiceChoice.create(choice: 'dipole-dipole attraction', multiple_choice: mc2)

mc3 = Embeddable::MultipleChoice.create!(name: "Multiple choice 2", prompt: "Which type of intermolecular attraction is strongest? ")
Embeddable::MultipleChoiceChoice.create(choice: 'London dispersion attraction', multiple_choice: mc3)
Embeddable::MultipleChoiceChoice.create(choice: 'dipole-dipole attraction', multiple_choice: mc3)

# Create an OpenResponse embeddable
or1 = Embeddable::OpenResponse.create!(name: "Open Response One", prompt: "Why is that true?")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page_3_boiling_point.add_embeddable(xhtml1, 1)
page_3_boiling_point.add_embeddable(mc1, 2)
page_3_boiling_point.add_embeddable(mc2, 3)
page_3_boiling_point.add_embeddable(mc3, 4)
page_3_boiling_point.add_embeddable(or1, 5)
### End Page 3 ###

## Page 4 ###
# This creates a page and adds it to the activity.
page_4_boiling_point = act_boiling_point.pages.create!(name: "Page 4", text: "Boiling point is a physical property that is determined by intermolecular attractions.")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_pn4 = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/sam/intermolecular-attractions/3-2-boiling-point-and-solubility.json")
# Add the same interactive to the page.
page_4_boiling_point.add_interactive(interactive_pn4)

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>The model shows a drop of a polar liquid and a drop of a non-polar liquid. By heating these liquids, you can vaporize (boil) them, causing molecules to break free of their intermolecular attractions.</p>")
xhtml2 = Embeddable::Xhtml.create!(name: "Xhtml 2", content: "<p>Heat the liquids and see if your prediction was correct.</p>")

# Create three MultipleChoice embeddables, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Which molecule will boil first?")
Embeddable::MultipleChoiceChoice.create(choice: 'polar', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'non-polar', multiple_choice: mc1)

mc2 = Embeddable::MultipleChoice.create!(name: "Multiple choice 2", prompt: "Which liquid boiled first?")
Embeddable::MultipleChoiceChoice.create(choice: 'polar', multiple_choice: mc2)
Embeddable::MultipleChoiceChoice.create(choice: 'non-polar', multiple_choice: mc2)

# Create an OpenResponse embeddable
or1 = Embeddable::OpenResponse.create!(name: "Open Response 1", prompt: "Why?")
or2 = Embeddable::OpenResponse.create!(name: "Open Response 2", prompt: "How could you tell when the liquids boiled?")
or3 = Embeddable::OpenResponse.create!(name: "Open Response 3", prompt: "Rubbing alcohol is a non-polar liquid and water is a polar liquid. Both are liquids at room temperature. Which one boils first? Why?")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page_4_boiling_point.add_embeddable(xhtml1, 1)
page_4_boiling_point.add_embeddable(mc1, 2)
page_4_boiling_point.add_embeddable(xhtml2, 3)
page_4_boiling_point.add_embeddable(or2, 4)
page_4_boiling_point.add_embeddable(mc2, 5)
page_4_boiling_point.add_embeddable(or3, 6)
### End Page 4 ###

#### End Activity Creation ####

#### Start creation of one activity ####
# Create the Intermolecular Attractions and Solubility activity
act_solubility = LightweightActivity.create!(name: "Intermolecular Attractions and Solubility")

### Page 1 ###
# This creates a page and adds it to the activity.
page1_solubility = act_solubility.pages.create!(name: "Page 1", text: "Have you ever wondered why oil and water don't mix? Why does salad dressing need to be shaken up before you pour it on your salad?")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_page1_solubility = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/samples/1-oil-and-water-shake.json")
# Add the same interactive to the page.
page1_solubility.add_interactive(interactive_page1_solubility)

## Add embeddables ##
# Create an OpenResponse embeddable
or1 = Embeddable::OpenResponse.create!(name: "Open Response One", prompt: "Why?")

mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Which part did you think was water?")
Embeddable::MultipleChoiceChoice.create(choice: 'white circles', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'colored circles', multiple_choice: mc1)

# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p><img src=\"/assets/lightweight/water-and-oil.jpg\" alt=\"Water and Oil\" />Shake up the \"salad dressing\" in the model below, and see if you can figure out which part is water and which part is oil.</p>")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page1_solubility.add_embeddable(xhtml1, 1)
page1_solubility.add_embeddable(or1, 2)
page1_solubility.add_embeddable(mc1, 3)

page1_solubility.sidebar = "<p><img src=\"/assets/lightweight/solubility-sidebar1.jpg\" alt=\"Rock Candy Sticks\" />Many people have enjoyed eating a stick of rock candy. Contrary to its name, rock candy is not made out of rocks. The rock shape arises from the shapes of the sugar crystals.</p><p>You can make your own rock candy at home.</p><ul><li>Prepare strings, skewers, or toothpicks to suspend into individual jars. You should make sure that the string, skewer, or toothpick doesn't touch the bottom of the jar, and make sure that you can suspend them stably (no rolling around!).</li><li>Boil 2 cups of water with 4.5 cups of sugar for 5 minutes, stirring frequently.  Make sure that all of the sugar dissolves.</li><li>Remove the syrup mixture from the heat, and stir in flavoring (2 teaspoons) and coloring if you wish.</li><li>Let the mixture stand, undisturbed, for 5 minutes.</li><li>Pour the mixture into individual jars and lower skewers or strings into the jars. After a couple of hours, you should start to see crystals. Let them grow until they reach the size you want, and then take them out and enjoy!</li></ul><p>Why does the sugar dissolve in the water? Intermolecular attractions! Delicious intermolecular attractions...</p>"
page1_solubility.save
### End Page 1 ###

## Page 2 ###
# This creates a page and adds it to the activity.
page2_solubility = act_solubility.pages.create!(name: "Page 2", text: "")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_page2_solubility = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/sam/intermolecular-attractions/1-introduction.json")
# Add the same interactive to the page.
page2_solubility.add_interactive(interactive_page2_solubility)

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>In the model, the white circles represent the oil and the colored circles represent the water.</p><p>Why don't they mix and stay mixed?</p><p>That has to do with the interactions between the molecules. The dotted lines between the molecules (represented by two bonded circles) show the attractions between the molecules.</p><p>Use this model to figure out which types of molecules are attracted to each other. Drag molecules around and see where the attractions are.</p>")

# Create one MultipleChoice embeddable, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Which molecules are attracted to each other?")
Embeddable::MultipleChoiceChoice.create(choice: 'white molecules and white molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'white molecules and colored molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'colored molecules and colored molecules', multiple_choice: mc1)

xhtml2 = Embeddable::Xhtml.create!(name: "Xhtml 2", content: "<p>The white molecules are non-polar molecules. This means that they don't have electrical charges.</p><p>The colored molecules are polar molecules. They have positive (blue) and negative (red) charges.</p><p>[img]</p><p>You may have noticed that the positive (blue) portions of the polar molecules did not form attractions to the positive portions of other polar molecules.</p>")

or1 = Embeddable::OpenResponse.create!(name: "Open Response One", prompt: "Why do you think this is?")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page2_solubility.add_embeddable(xhtml1, 1)
page2_solubility.add_embeddable(mc1, 2)
page2_solubility.add_embeddable(xhtml2, 3)
page2_solubility.add_embeddable(or1, 4)
### End Page 2 ###

## Page 3 ###
# This creates a page and adds it to the activity.
page3_solubility = act_solubility.pages.create!(name: "Page 3", text: "")

# Create an interactive to add to this page. (Interactives can only belong to one page,
# so for the second page we need another new interactive.)
interactive_page3_solubility = MwInteractive.create!(name: "MW model", url: "http://lab.concord.org/interactives.html#interactives/sam/intermolecular-attractions/2-comparing-dipole-dipole-to-london-dispersion.json")
# Add the same interactive to the page.
page3_solubility.add_interactive(interactive_page3_solubility)

## Add embeddables ##
# Create an (X)HTML embeddable.
xhtml1 = Embeddable::Xhtml.create!(name: "Xhtml 1", content: "<p>By now, you have figured out that all molecules are attracted to each other.  But if that's true, then why don't water and oil mix and stay mixed?</p><p>The answer lies in the strength of the attractions.</p><p>Use the model below to figure out how strong the attractions are between:</p><ul><li>two non-polar molecules</li><li>two polar molecules</li><li>one polar molecule and one non-polar molecule</li></ul><p>Before you play with the model, predict what the strength of each attraction will be.</p>")

# Create three MultipleChoice embeddables, with choices
mc1 = Embeddable::MultipleChoice.create!(name: "Multiple choice 1", prompt: "Which molecules are most strongly attracted to each other?")
Embeddable::MultipleChoiceChoice.create(choice: 'two non-polar molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'two polar molecules', multiple_choice: mc1)
Embeddable::MultipleChoiceChoice.create(choice: 'one polar molecule and one non-polar molecule', multiple_choice: mc1)

# Create an OpenResponse embeddable
or1 = Embeddable::OpenResponse.create!(name: "Open Response One", prompt: "Why do you think this is true?")
or2 = Embeddable::OpenResponse.create!(name: "Open Response Two", prompt: "So, now can you explain why oil and water don't mix well with each other?")

# Add the embeddables created above to the page. The order they are added is the order
# they will be displayed: first on top, last on the bottom.
page3_solubility.add_embeddable(xhtml1, 1)
page3_solubility.add_embeddable(mc1, 2)
page3_solubility.add_embeddable(or1, 3)
page3_solubility.add_embeddable(or2, 4)
### End Page 3 ###

#### End Activity Creation ####
