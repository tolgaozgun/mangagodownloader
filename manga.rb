require 'watir' # Crawler
require 'pry' # Ruby REPL
require 'rb-readline' # Ruby IRB
require 'awesome_print' # Console output
require_relative 'credentials'
require 'open-uri'

manganame= $manganame
chapter = $chapter
filepath = $filepath
browser = Watir::Browser.new :chrome
browser.goto "mangago.me/read-manga/#{manganame}"

browser.a(:text => "Start Reading").click()
Watir::Wait.until { browser.windows.size == 2 }
browser.window(:index => 1).use
count = $frompage
if chapter > 1
  browser.a(:class => "chapter").click()
  Watir::Wait.until{
    browser.ul(:class => "chapter").visible?
   }
  chapterbutton = browser.ul(:class => "chapter").a(:index => chapter - 1)
  chaptername = chapterbutton.text
  chapterbutton.click()
  sleep(1.0)
end
  while !browser.img(:id => "page#{count}").exists? do
    browser.a(:text => "Pg 1").click()
    sleep(0.1)
    browser.ul(:id =>"dropdown-menu-page").li(:index => count - 1).click()
    sleep(1.0)
end
size = browser.ul(:id => "dropdown-menu-page").lis().size
Dir.mkdir(filepath + manganame + '/' + chaptername) unless File.exists?(filepath + manganame + "/" + chaptername)
while count < size + 1 do
  filename = "page#{count}.png"
  image_src = browser.img(:class => "page#{count}").src
  clickthis = browser.img(:id => "page#{count}")
  open(filepath + manganame + '/' + chaptername + '/' + filename, 'wb') do |file|
					file << open(image_src).read
				end
        while !browser.img(:class => "page#{count + 2}").exists? do
          if count + 2 > size
             browser.a(:class => "next_page").click()
             sleep(1.0)
             break
           end
          browser.a(:class => "next_page").click()
          sleep(1.0)
        end
  ap "Page #{count}/#{size} saved."
  count+= 1
  sleep(0.5)
end
