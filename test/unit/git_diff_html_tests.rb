require File.dirname(__FILE__) + '/../test_helper'
require 'GitDiff'

# > ruby test/unit/git_diff_html_tests.rb

class GitDiffHtmlTests < ActionController::TestCase

  include GitDiff
  
  test "mixture with more than 9 lines" do
    diffed =
    [
      { :line => "once",              :type => :same,    :number => 1 },
      { :line => "upon a",            :type => :same,    :number => 2 },
      { :line => "time",              :type => :same,    :number => 3 },
      { :line => "IN",                :type => :deleted               },
      { :line => "in",                :type => :added,   :number => 4 },
      { :line => "the west",          :type => :same,    :number => 5 },
      { :line => "Charles Bronson",   :type => :same,    :number => 6 },
      { :line => "Jason Robarts",     :type => :same,    :number => 7 },
      { :line => "Henry Fonda",       :type => :same,    :number => 8 },
      { :line => "Claudia Cardinale", :type => :same,    :number => 9 },
      { :line => "Sergio Leone",      :type => :added,   :number => 10 },
      { :line => "Ennio Morricone",   :type => :same,    :number => 11 },
    ]    
    expected =
    [ 
        "<same><ln>  1</ln>once</same>",
        "<same><ln>  2</ln>upon a</same>",
        "<same><ln>  3</ln>time</same>",
        "<deleted><ln>  -</ln>IN</deleted>",
        "<added><ln>  4</ln>in</added>",
        "<same><ln>  5</ln>the west</same>",
        "<same><ln>  6</ln>Charles Bronson</same>",
        "<same><ln>  7</ln>Jason Robarts</same>",
        "<same><ln>  8</ln>Henry Fonda</same>",
        "<same><ln>  9</ln>Claudia Cardinale</same>",
        "<added><ln> 10</ln>Sergio Leone</added>",
        "<same><ln> 11</ln>Ennio Morricone</same>",        
    ].join("\n")
    
    assert_equal expected, git_diff_html(diffed)
  end
  
  # - - - - - - - - - - - - - - - - - - - - - - - -
  
  test "some lines same some lines added some lines deleted" do
    diffed =
    [
      { :line => "once",     :type => :same,    :number => 1 },
      { :line => "upon a",   :type => :same,    :number => 2 },
      { :line => "time",     :type => :same,    :number => 3 },
      { :line => "IN",       :type => :deleted               },
      { :line => "in",       :type => :added,   :number => 4 },
      { :line => "the west", :type => :same,    :number => 5 },
    ]    
    expected =
    [ 
        "<same><ln>  1</ln>once</same>",
        "<same><ln>  2</ln>upon a</same>",
        "<same><ln>  3</ln>time</same>",
        "<deleted><ln>  -</ln>IN</deleted>",
        "<added><ln>  4</ln>in</added>",
        "<same><ln>  5</ln>the west</same>",
    ].join("\n")
    
    assert_equal expected, git_diff_html(diffed)
  end  
  
  # - - - - - - - - - - - - - - - - - - - - - - - -

  test "some lines same some lines added" do
    diffed =
    [
      { :line => "once",     :type => :same, :number => 1 },
      { :line => "upon a",   :type => :same, :number => 2 },
      { :line => "time",     :type => :same, :number => 3 },
      { :line => "in",       :type => :added,:number => 4 },
      { :line => "the west", :type => :same, :number => 5 },
    ]    
    expected =
    [ 
        "<same><ln>  1</ln>once</same>",
        "<same><ln>  2</ln>upon a</same>",
        "<same><ln>  3</ln>time</same>",
        "<added><ln>  4</ln>in</added>",
        "<same><ln>  5</ln>the west</same>",
        ].join("\n")
    
    assert_equal expected, git_diff_html(diffed)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - -
  
  test "all lines same" do
    diffed =
    [
      { :line => "once",        :type => :same, :number => 1 },
      { :line => "upon a",      :type => :same, :number => 2 },
      { :line => "time",        :type => :same, :number => 3 },
      { :line => "in the west", :type => :same, :number => 4 },
    ]
    
    expected =
    [ 
        "<same><ln>  1</ln>once</same>",
        "<same><ln>  2</ln>upon a</same>",
        "<same><ln>  3</ln>time</same>",
        "<same><ln>  4</ln>in the west</same>"
    ].join("\n")
    
    assert_equal expected, git_diff_html(diffed)
  end
    
end
