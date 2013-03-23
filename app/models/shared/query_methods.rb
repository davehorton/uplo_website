module Shared
  module QueryMethods
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # returns a paginated, sorted collection scope
      # params:
      #   page: current page, defaults to 1
      #   per_page: number of results to return at a time, or the WillPaginate default
      #   sort_field: name, ignored if sort_expression set
      #   sort_direction: asc or desc, ignored if sort_expression set
      #   sort_expression: custom sort expression
      def paginate_and_sort(params = {})
        params[:page] ||= 1
        scoped_object = paginate(params.slice(:page, :per_page))
        sort_criteria = extract_sort_options(params)
        scoped_object = scoped_object.reorder(sort_expression(sort_criteria)) if sort_criteria.any?
        scoped_object
      end

      private

        def extract_sort_options(params)
          params.slice(:sort_field, :sort_direction, :sort_expression)
        end

        def sort_expression(opts)
          opts[:sort_expression] ||= begin
            opts[:sort_field] ||= 'id'
            opts[:sort_direction] ||= 'desc'
            sanitize_sql_array ["%s %s", opts[:sort_field], opts[:sort_direction]]
          end
          opts[:sort_expression]
        end
    end
  end
end