export interface PaginationOptions {
  page: number;
  limit: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
}

export function normalizePagination(page?: number, limit?: number): PaginationOptions {
  const p = page && page > 0 ? page : 1;
  const l = limit && limit > 0 ? Math.min(limit, 100) : 20;
  return { page: p, limit: l };
}

export function toPaginated<T>(
  data: T[],
  total: number,
  opts: PaginationOptions,
): PaginatedResult<T> {
  return { data, total, page: opts.page, limit: opts.limit };
}
