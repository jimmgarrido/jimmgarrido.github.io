#Jekyll-Photo-Gallery generates a HTML page for every photo specified in _data/photos.yaml
#Author: Theo Winter (https://github.com/aerobless)

module Jekyll
  class PhotoPage < Page
    def initialize(site, base, dir, photo_url, previous_pic, next_pic, title, description)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'photo.html')
      self.data['photo_url'] = photo_url
      self.data['previous_pic'] = previous_pic
      self.data['next_pic'] = next_pic
      # self.data['title'] = title
      self.data['description'] = description
      self.data['comments'] = true
    end
  end

  class PhotoList < Page
    def initialize(site, base, dir, photolist, title)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'photoIndex.html')
      self.data['photolist'] = photolist
      self.data['title'] = title
    end
  end

  class PhotoPageGenerator < Generator
    safe true

    def generate(site)
      data = YAML::load_file('_data/photos.yaml')
      dir = site.config['photo_dir'] || 'photography'
      host = data["host"]
      photos = data["photos"]
      # site.pages << PhotoList.new(site, site.source, File.join(dir), photos, "Photography")

      #Reference in site, used for sitemap
      photoSlugs = Array.new

      [nil, *photos, nil].each_cons(3) {|prev, curr, nxt|
        photo_url = host + curr["img"]
        # title = curr["title"]& || ""
        title = ""
        description = curr["description"]
        # title_stub = title&.strip&.gsub(' ', '-')&.gsub(/[^\w-]/, '') || "" #remove non-alpha and replace spaces with hyphens
        if(prev != nil)
          previous_pic = prev["title"]&.strip&.gsub(' ', '-')&.gsub(/[^\w-]/, '') || ""
        else
          previous_pic = ""
        end
        if(nxt != nil)
          next_pic = nxt["title"]&.strip&.gsub(' ', '-')&.gsub(/[^\w-]/, '') || ""
        else
          next_pic = ""
        end
        photoSlugs << photo_url
        # site.pages << PhotoPage.new(site, site.source, File.join(dir, title_stub), photo_url, previous_pic, next_pic, title, description)
      }
      site.data['photoSlugs'] = photoSlugs

      # #Create a array containing all countries
      # countryArray = Array.new
      # photos.each do |photo,details|
      #   [nil, *details, nil].each_cons(3){|prev, curr, nxt|
      #     photoCountry = curr["country"]
      #     countryArray.push(photoCountry)
      #   }
      # end
      # countryArray = countryArray.uniq

      # countryArray.each do |name|
      #   photosPerCountry = Array.new
      #   countrySlug = name&.strip&.gsub(' ', '-')&.gsub(/[^\w-]/, '') || ""
      #   photos.each do |photo, details|
      #     [nil, *details, nil].each_cons(3){|prev, curr, nxt|
      #       if(curr["country"] == name)
      #         photosPerCountry.push(curr)
      #       end
      #     }
      #   end

      #   #Make page
      #   site.pages << PhotoList.new(site, site.source, File.join('photography', countrySlug), photosPerCountry, name)
      # end
    end
  end
end

module TextFilter
  def toStub(input)
    input.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  end
end

Liquid::Template.register_filter(TextFilter)

module Jekyll
  class IncludeGalleryTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @result = '<div id="gallery" style="display:none; margin-bottom: 20px;">'
      data = YAML::load_file('_data/photos.yaml')
      host = data["host"]
      photos = data["photos"]
      photos.each do |photo|
        title = ""
        if(photo["album"] == text.strip)
          @result = @result+'<div itemscope itemtype="http://schema.org/Photograph">
                                  <a itemprop="image" class="swipebox" title="'+title+'" href="'+host+photo["album"]+'/'+photo["img"]+'">
                                    <img alt="'+title+'" itemprop="thumbnailUrl" src="'+host+photo["album"]+'/'+photo["img"]+'"/>
                                  </a>
                                </div>'
        end
      end
      @result = @result + '</div>'

      #If you want to configure each album gallery individually you can remove this script
      #and add it in the template/post directly.
      @result = @result + '<script>
                              window.onload=function(){
                                  $("#gallery").justifiedGallery({
                                      rowHeight : 220,
                                      maxRowHeight: 340,
                                      margins : 5,
                                      border : 0,
                                      fixedHeight: false,
                                      lastRow : \'nojustify\',
                                      captions: true
                                  }).on("jg.complete", function () {
                                    $(".swipebox").swipebox();
                                });
                                  $("#gallery").fadeIn(500);
                              }
                          </script>'
    end

    def render(context)
      "#{@result}"
    end
  end
end
Liquid::Template.register_tag('includeGallery', Jekyll::IncludeGalleryTag)
