require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require_relative 'credentials' # For getting variables
require 'open-uri' # Save image files

manganame= $manganame
chapter = $chapter
filepath = $filepath
count = $frompage

browser = Watir::Browser.new :chrome                  # Opens up a new Chrome browser
browser.goto "mangago.me/read-manga/#{manganame}"     # Visits the manga page.

browser.a(:text => "Start Reading").click()           # Opens up the manga page.
Watir::Wait.until { browser.windows.size == 2 }     
browser.window(:index => 1).use                       # Waits for the page to load and selects the page.
if chapter > 1                                        # If chapter is not set to 1, it will load the chapter
  browser.a(:class => "chapter").click()              # from the menu.
  Watir::Wait.until{
    browser.ul(:class => "chapter").visible?
   }
  chapterbutton = browser.ul(:class => "chapter").a(:index => chapter - 1)
  chaptername = chapterbutton.text                    # Will be used for the folder name.
  chapterbutton.click()                               # Loads the chapter.
  sleep(1.0)
end
  while !browser.img(:id => "page#{count}").exists? do                        # If starting page is not set to 1,
    browser.a(:text => "Pg 1").click()                                        # it will find the page number specified.
    sleep(0.1)
    browser.ul(:id =>"dropdown-menu-page").li(:index => count - 1).click()
    sleep(1.0)
end
size = browser.ul(:id => "dropdown-menu-page").lis().size                     # Pages in the chapter
Dir.mkdir(filepath + manganame + '/' + chaptername) unless File.exists?(filepath + manganame + "/" + chaptername) # Creates the directory
while count < size + 1 do                                                     # Loops through all remaining pages.
  filename = "page#{count}.png"
  image_src = browser.img(:class => "page#{count}").src
  clickthis = browser.img(:id => "page#{count}")
  open(filepath + manganame + '/' + chaptername + '/' + filename, 'wb') do |file|
					file << open(image_src).read
				end
        while !browser.img(:class => "page#{count + 2}").exists? do           # To understand when it skips the page
          if count + 2 > size    # This part is for the last 2 pages.         # For example page3 is loaded when you visit                                  
             browser.a(:class => "next_page").click()                         # page2, but page4 is not.
             sleep(1.0)                                                       # It scans for page4 whenever you try to switch
             break                                                            # from page2 to page3. When it finds page4
           end                                                                # it means you switched to page3.
          browser.a(:class => "next_page").click()
          sleep(1.0)
        end
  ap "Page #{count}/#{size} saved."
  count+= 1
end
