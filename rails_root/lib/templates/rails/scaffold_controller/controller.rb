class <%= controller_class_name %>Controller < ApplicationController

  def index
    @<%= plural_table_name %> = <%= orm_class.all(class_name) %>

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def show
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    if @<%= singular_table_name %>.blank?
      error_routing
    else
      respond_to do |format|
        format.html # show.html.erb
      end
    end
  end

  def new
    @<%= singular_table_name %> = <%= orm_class.build(class_name) %>

    respond_to do |format|
      format.html # new.html.erb
    end
  end


  def edit
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    if @<%= singular_table_name %>.blank?
      error_routing
    else
      render
    end
  end

  def create
    @<%= singular_table_name %> = <%= orm_class.build(class_name, "params[:#{singular_table_name}]") %>

    respond_to do |format|
      if @<%= orm_instance.save %>
        format.html { redirect_to(@<%= singular_table_name %>, :notice => '<%= human_name %> was successfully created.') }
      else
        format.html { render :action => "new" }
      end
    end
  end


  def update
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>

    respond_to do |format|
      if @<%= orm_instance.update_attributes("params[:#{singular_table_name}]") %>
        format.html { redirect_to(@<%= singular_table_name %>, :notice => '<%= human_name %> was successfully updated.') }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @<%= singular_table_name %> = <%= orm_class.find(class_name, "params[:id]") %>
    if @<%= singular_table_name %>.blank?
      flash[:error] = 'Unable to delete <%= human_name %>'
      error_routing
    else
      @<%= orm_instance.destroy %>

      respond_to do |format|
        format.html { redirect_to(<%= index_helper %>_url) }
      end
    end
  end
end

