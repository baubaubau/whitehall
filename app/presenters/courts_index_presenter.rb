class CourtsIndexPresenter < Array

  def courts
    self.class.new(grouped_organisations[:court] || [])
  end

  def tribunals
    self.class.new(grouped_organisations[:tribunal] || [])
  end

  private

  def grouped_organisations
    @grouped_organisations ||= group_by { |org| org.type.key }
  end
end
