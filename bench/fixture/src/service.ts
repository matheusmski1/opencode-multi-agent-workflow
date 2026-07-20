import { InMemoryTaskRepository } from './repository';
import type { CreateTaskInput, Task } from './types';

let counter = 0;
const nextId = (): string => `task-${(counter += 1)}`;

export class TaskService {
  constructor(private readonly repo: InMemoryTaskRepository) {}

  createTask(input: CreateTaskInput): Task {
    const title = input.title.trim();
    if (title.length === 0) {
      throw new Error('title is required');
    }
    const task: Task = {
      id: nextId(),
      title,
      status: 'open',
      createdAt: new Date().toISOString(),
    };
    this.repo.add(task);
    return task;
  }

  completeTask(id: string): Task {
    const task = this.repo.findById(id);
    if (!task) {
      throw new Error(`task ${id} not found`);
    }
    const done: Task = { ...task, status: 'done' };
    this.repo.update(done);
    return done;
  }

  archiveTask(id: string): Task {
    const task = this.repo.findById(id);
    if (!task) {
      throw new Error(`task ${id} not found`);
    }
    const archived: Task = { ...task, status: 'archived' };
    this.repo.update(archived);
    return archived;
  }

  // BENCHMARK SEED — do NOT pre-fix this.
  // Only excludes 'done'; 'archived' tasks leak through. The L2 debug task targets this.
  listOpen(): Task[] {
    return this.repo.list().filter((task) => task.status !== 'done');
  }
}
