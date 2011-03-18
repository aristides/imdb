module Imdb

  class MovieList
    def movies (movies = nil)
      if movies.nil?
        @movies ||= parse_movies
      else
        @movies = movies
      end
    end
    
    private
    def parse_movies
      document.search('a[@href^="/title/tt"]').reject do |element|
        element.innerHTML.imdb_strip_tags.empty? ||
        element.parent.innerHTML =~ /media from/i ||
        element.parent.innerHTML =~ /Material de midia/
      end.map do |element|
        id = element['href'][/\d+/]
        
        data = element.parent.innerHTML.split("<br />")
        if !data[0].nil? && !data[1].nil? && data[0] =~ /img/
          title = data[1]
        else
          title = data[0]
        end
        
        title = title.imdb_strip_tags.imdb_unescape_html
        title.gsub!(/\s+\(\d\d\d\d\)$/, '')

        #search for the thumb
        if element.parent.parent.innerHTML =~ /\"(http:.*jpg)\"/
          thumblink = $1
        end

        #search for the movie type
        if element.parent.innerHTML =~ /<small>(.*)<\/small>/ || element.parent.innerHTML =~ /(\(TV\))>/
          type = $1
        end

#         = Hpricot(element.parent.parent.innerHTML).search('img[@src^="media"]').first['src']

        [id, title, thumblink, type]
      end.uniq.map do |values|
        Imdb::Movie.new(*values)
      end
    end
  end # MovieList

end # Imdb
