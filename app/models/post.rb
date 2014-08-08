class Post < ActiveRecord::Base
  belongs_to :creator, foreign_key: 'user_id', class_name: 'User'
  has_many :comments
  has_many :post_categories
  has_many :categories, through: :post_categories
  has_many :votes, as: :voteable

  validates :title, presence: true, length: {minimum: 5}
  validates :url, presence: true, uniqueness: true
  validates :description, presence: true

  before_save :generate_slug!

  def total_votes
    self.up_votes - self.down_votes
  end

  def up_votes
    self.votes.where(vote: true).size
  end

  def down_votes
    self.votes.where(vote: false).size
  end

  def to_param
    self.slug
  end
  
  # check if my-google, my-google-2,my-google-3 ... exit, and then add suffix
  def generate_slug!
    the_slug = to_slug(self.title)
    post = Post.find_by slug: the_slug
    count = 2
    while post && post != self
      the_slug = append_suffix(the_slug, count)
      post = Post.find_by slug: the_slug
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
end
