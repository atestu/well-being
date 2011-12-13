require 'rubygems'
require 'sinatra'
require 'hpricot'
require 'open-uri'

# (1) grab the overall frequency of four keywords (perhaps more word
# later) -- "happy," "sad," "hopeful," "hopeless" -- and the word "the."
# 
# (2) grab a "point" frequency of those four keywords & "the."
# 
# (3) normalize the overall frequency of each keyword by the overall
# frequency of "the."
# 
# (4) normalize the point frequency of each keyword by the point
# frequency of "the."
# 
# (5) the "surprisingness" of the keyword is: (4)/(3).
# 
# (6) the happiness index is: (surprisingness of happy)/(surprisingness of sad).
# 
# (7) the optimism index is: (surprisingness of hopeful)/(surprisingness
# of hopeless).
# 
# (8) and the "well being" index is: (6)/[1/(7)].


class WordIndex
  def getResultCounts # get the number of results by crawling Google
    searches.each { |search|
      puts search
      doc = open(search) { |f| Hpricot(f) }
      @printSearchCounts.push((doc/"#subform_ctrl/div/b")[2].inner_html)
    }
    @printSearchCounts.each { |count| 
      @searchCounts.push(count.gsub(',', '').to_i)
    }
  end
  def computeSurprisingness(norm) # get the surprisingness (normalized via the number of results for the word norm)
    
  end
  def computeIndex # compute the index
    
  end  
  def Searches # table of searches to perform
    ["https://www.google.com/search?&q=#{@word}+site%3Atwitter.com&hl=en&lr=&cr=countryUS&tbs=ctr%3AcountryUS", # twitter
      "https://www.google.com/search?&q=#{@word}&hl=en&cr=countryUS&tbs=ctr%3AcountryUS&tbm=blg",               # blogs
      "https://www.google.com/search?q=#{@word}&num=100&hl=en&cr=countryUS&tbs=ctr:countryUS,dtf:f&tbm=dsc",    #fora
      ",cdr:1,cd_min:11/1/2008,cd_max:12/1/2008"
    ]
     
     
      # "https://www.google.com/search?q=#{@word}&hl=en&cr=countryUS&tbs=ctr:countryUS&tbm=nws&source=lnms"]
  end
  def initialize(word, from, to)
    @word = word
    @from = from # start date
    @to = to # end date
    @searchCounts = []
    @printSearchCounts = []
    @surprisingness = 0
  end
  attr_accessor :word, :searchCounts, :printSearchCounts, :surprisingness
  # searchCounts is a table of the number of results for each search
  # printSearchCounts is searchCounts but for pretty printing (with a comma)
end

get '/:keyword' do
  @wordIndex = WordIndex.new(params[:keyword])
  @wordIndex.getResultCounts
  erb :word
end

get '/' do
  keywordsTable = ['happy', 'sad', 'hopeful', 'hopeless']
  @wordIndexTable = []
  
  theIndex = WordIndex.new('the')
  theIndex.getResultCounts

  keywordsTable.each { |word|
    @wordIndexTable.push(WordIndex.new(word))
  }
  
  @wordIndexTable.each { |wordIndex|
    wordIndex.getResultCounts
  }
  
  erb :index
end