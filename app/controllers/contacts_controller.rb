
require "csv"

class ContactsController < ApplicationController

  allow_unauthenticated_access only: [
    :index, :new, :create, :destroy
  ]

  def index
    @contacts = Contact.order(:name)

    respond_to do |format|
      format.html

      # Eksport CSV
      format.csv do
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

      # Eksport VCF
      format.vcf do
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

  # Formularz nowego kontaktu
  def new
    @contact = Contact.new
  end

  # Dodawanie kontaktu
  def create
    @contact = Contact.new(contact_params)

    if @contact.save
      redirect_to contacts_path,
                  notice: "Kontakt dodany!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Usuwanie kontaktu
  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy!

    redirect_to contacts_path,
                notice: "Kontakt usunięty!"
  end

  private

  def vcard_escape(value)
    value.to_s.gsub(/\\|,|;|\r\n|\r|\n/) do |character|
      case character
      when "\\" then "\\\\"
      when "," then "\\,"
      when ";" then "\\;"
      else "\\n"
      end
    end
  end

  def contact_params
    params.require(:contact).permit(
      :name, :phone, :category
    )
  end

end
