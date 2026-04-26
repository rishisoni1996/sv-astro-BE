export function trimPhoneNumber(phoneNumber: string): string {
  // Remove +, (, ), spaces, -, and any other non-digit characters
  return phoneNumber.replace(/[^0-9]/g, '');
}
