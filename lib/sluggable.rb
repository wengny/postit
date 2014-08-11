module Sluggable
  extend ActiveSupport::Concern

  included do
    before_save :generate_slug!
    class_attribute :slug_column
  end

  def to_param
    self.slug
  end
  
  # check if my-google, my-google-2,my-google-3 ... exit, and then add suffix
  def generate_slug!
    #self.send(self.class.slug_column.to_sym) equals to  self.title 
    the_slug = to_slug(self.send(self.class.slug_column.to_sym))
    obj = self.class.find_by slug: the_slug
    count = 2
    while obj && obj != self
      the_slug = append_suffix(the_slug, count)
      obj = self.class.find_by slug: the_slug
      count += 1
    end
    self.slug = the_slug
  end

  def append_suffix(str, count)
    if str.split('-').last.to_i != 0  # my-google-2, my-google-3 ....
      return str.split('-').slice(0...-1).join('-')+ "-"+count.to_s # input: "my-google-2", output: "my-google"+"-"+count
    else # my-google
      return str + "-" + count.to_s
    end
  end

  def to_slug(str)
    str.strip!                     #strip the beginnin and ending space, ! mutuate the str
    str.gsub! /[^a-zA-Z\d]/i, '-'  #replace all non-alp and non-num character to -
    str.gsub! /-+/, '-'            #replace multiple - to one -
    str.downcase                           
  end

  module ClassMethods
    def sluggable_column(col_name)
      self.slug_column = col_name
    end
  end
end