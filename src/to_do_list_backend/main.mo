import Text "mo:base/Text";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

actor ToDoListApp {
    // Görev yapısı
    type Task = {
        id: Nat;
        description: Text;
        completed: Bool;
    };

    // Görev kimliği için sayaç
    stable var nextId : Nat = 1;

    // Gelişmiş hash fonksiyonu
    func natHash(n : Nat) : Hash.Hash {
        Text.hash(Nat.toText(n));
    };

    // Görevleri saklamak için HashMap
    let tasks = HashMap.HashMap<Nat, Task>(
        0, 
        Nat.equal, 
        natHash
    );

    // Yeni görev ekleme fonksiyonu
    public func addTask(description : Text) : async Nat {
        let taskId = nextId;
        let newTask : Task = {
            id = taskId;
            description = description;
            completed = false;
        };
        
        tasks.put(taskId, newTask);
        nextId += 1;
        
        return taskId;
    };

    // Tüm görevleri listeleme fonksiyonu
    public query func listTasks() : async [Task] {
        return Array.map(Iter.toArray(tasks.vals()), func(task: Task) : Task { task });
    };

    // Görevi tamamlama fonksiyonu
    public func completeTask(taskId : Nat) : async ?Task {
        switch (tasks.get(taskId)) {
            case null { null };
            case (?task) {
                let updatedTask : Task = {
                    id = task.id;
                    description = task.description;
                    completed = true;
                };
                tasks.put(taskId, updatedTask);
                ?updatedTask;
            };
        };
    };

    // Görevi silme fonksiyonu
    public func deleteTask(taskId : Nat) : async Bool {
        switch (tasks.get(taskId)) {
            case null { false };
            case (?_) { 
                tasks.delete(taskId);
                true; 
            };
        };
    };

    // Tamamlanmamış görevleri listeleme fonksiyonu
    public query func listUncompletedTasks() : async [Task] {
        Array.filter(
            Iter.toArray(tasks.vals()), 
            func(task : Task) : Bool { not task.completed }
        );
    };
}