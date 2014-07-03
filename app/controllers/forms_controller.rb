class FormsController < ApplicationController
  def index
    @forms = Form.all
  end

  def new
    @form = Form.new
  end

  def create
    @form = Form.find_or_create_by(id: params[:id])
    @form.update_attributes(
      title: params[:title],
      uid: makeuid(params[:title], @form.id)
    )

    if current_user
      @form.update_attribute(:user_id, current_user.id)
    end
    render json: @form
  end

  def show
    @form = Form.find(params[:id])
    respond_to do |format|
      format.html
      format.json { render json: @form, include: :inputs }
    end
  end

  def show_xml
    @form = Form.find(params[:id])
  end

  def edit
  end

  def update
    @form = Form.find(params[:id])
    inputs = params[:inputs]

    inputs.each_with_index do |input, index|
      item = Input.find_or_create_by(id: input[:id])
      item.update_attribute(:order, index)
    end

    @forms = Form.all
    # Redirect to Index
    # redirect_to action: "index", method: :get, format: 'html'
  end

  def destroy
  end

  private 

  def form_params(params)
    params.require(:form).permit(:title)
  end



end
