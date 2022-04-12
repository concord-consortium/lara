class CollectionFilter
  attr_accessor :my, :user, :klass, :limit, :search
  VALID_PARAMS = [:my, :limit, :search]

  def initialize(user,klass, attributes = {})
    @user  = user
    @klass = klass
    update_from_params(attributes||{})
  end

  def update_from_params(params={})
    params.each do |name, value|
      next unless VALID_PARAMS.include? name.to_sym
      send("#{name}=".to_sym, value)
    end
  end

  def collection
    if @search
      results = @klass.search(@search, @user)
    elsif @my && @user
      results = @klass.my(@user)
    elsif @user
      results = @klass.visible(@user)
    else
      results = @klass.public
    end
    results.limit(self.limit) if @limit and results.respond_to? :limit
    results.newest
  end
end