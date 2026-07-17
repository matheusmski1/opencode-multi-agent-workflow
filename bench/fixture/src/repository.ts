import type { Task } from './types';

export class InMemoryTaskRepository {
  private readonly tasks = new Map<string, Task>();

  add(task: Task): void {
    this.tasks.set(task.id, task);
  }

  findById(id: string): Task | undefined {
    return this.tasks.get(id);
  }

  list(): Task[] {
    return [...this.tasks.values()];
  }

  update(task: Task): void {
    if (!this.tasks.has(task.id)) {
      throw new Error(`task ${task.id} not found`);
    }
    this.tasks.set(task.id, task);
  }
}
