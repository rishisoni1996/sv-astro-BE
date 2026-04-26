import { format, formatDistanceToNowStrict } from 'date-fns';

export function formatDateBadge(date: Date): string {
  return format(date, 'EEE · MMM d');
}

export function formatRenewsLabel(date: Date): string {
  return `Renews ${format(date, 'MMMM d, yyyy')}`;
}

export function formatMemberSince(date: Date): string {
  return format(date, 'MMM yyyy');
}

export function formatLastSeen(date: Date): string {
  return `${formatDistanceToNowStrict(date)} ago`;
}

export function formatDayNumber(date: Date): string {
  return format(date, 'd');
}

export function formatDayName(date: Date): string {
  return format(date, 'EEE');
}

export function formatClock(date: Date): string {
  return format(date, 'h:mm a');
}
