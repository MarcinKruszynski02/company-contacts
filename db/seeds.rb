
# Konto demonstracyjne administratora

if Rails.env.development?
  admin = User.find_or_initialize_by(
    email_address: "admin@firma.pl"
  )

  admin.password = "admin123"
  admin.password_confirmation = "admin123"
  admin.save!

  puts "Konto administratora jest gotowe!"
end
