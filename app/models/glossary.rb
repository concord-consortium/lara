
# Simple mock Glossary from spike
# see also views/shared/_glossary.html.haml
# TODO: Make this an AR model, belonging to a LightweightActivity.
class Glossary

  def words
     ['intro','poem', 'color', 'dont']
  end

  def replace
    '<span class="cc-glossary-word">$1</span>'
  end
end