// Domain/Enums/PaymentMethod.cs

namespace WelloraHealthCareManagement.Domain.Enums
{
    public enum PaymentMethod
    {
        Card = 0,           // Credit/Debit Card
        VodafoneCash = 1,   // Vodafone Cash
        EtisalatCash = 2,   // Etisalat Cash
        OrangeCash = 3,     // Orange Money
        WePay = 4,          // we Pay
        Valu = 5,           // Valu (BNPL)
        Souhoola = 6,       // Souhoola
        BankInstallment = 7 // Bank installments
    }
}