import { describe, it, expect } from 'vitest';
import { InMemoryTaskRepository } from './repository';
import { TaskService } from './service';

describe('TaskService', () => {
  it('cria uma task com status aberto', () => {
    const service = new TaskService(new InMemoryTaskRepository());
    const task = service.createTask({ title: 'Estudar' });
    expect(task.status).toBe('open');
  });

  it('rejeita título vazio', () => {
    const service = new TaskService(new InMemoryTaskRepository());
    expect(() => service.createTask({ title: '   ' })).toThrow();
  });

  it('completa uma task existente', () => {
    const service = new TaskService(new InMemoryTaskRepository());
    const task = service.createTask({ title: 'Escrever' });
    expect(service.completeTask(task.id).status).toBe('done');
  });
});
