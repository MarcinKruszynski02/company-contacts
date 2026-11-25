require "csv"

class ContactsController < ApplicationController


  allow_unauthenticated_access only: [
    :index, :new, :create
  ]

  def destroy
  @contact = Contact.find(params[:id])
  @contact.destroy!

  redirect_to contacts_path, notice: "Kontakt usunięty!"
end


def index
  @contacts = Contact.order(:name)

  respond_to do |format|
    format.html

    format.csv do
      unless authenticated?
        head :forbidden
        return
      end

      csv_data = CSV.generate(
        headers: true,
        col_sep: ";"
      ) do |csv|
        csv << ["name", "phone", "category"]

        @contacts.each do |contact|
          csv << [
            contact.name,
            contact.phone,
            contact.category
          ]
        end
      end

      send_data csv_data,
                filename: "kontakty.csv",
                type: "text/csv; charset=utf-8"
    end

    format.vcf do
      unless authenticated?
        head :forbidden
        return
      end

      vcf_data = @contacts.map do |contact|
        [
          "BEGIN:VCARD",
          "VERSION:3.0",
          "FN:#{vcard_escape(contact.name)}",
          "TEL;TYPE=WORK:#{vcard_escape(contact.phone)}",
          "NOTE:#{vcard_escape(contact.category)}",
          "END:VCARD"
        ].join("\r\n")
      end.join("\r\n") + "\r\n"

      send_data vcf_data,
                filename: "kontakty.vcf",
                type: "text/vcard; charset=utf-8"
    end
  end
end


  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to contacts_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def vcard_escape(value)
  value.to_s
       .gsub("\\", "\\\\\\")
       .gsub(/\r\n|\r|\n/, "\\n")
       .gsub(",", "\\,")
       .gsub(";", "\\;")
end


  def contact_params
    params.require(:contact).permit(:name, :phone, :category)
  end
end
