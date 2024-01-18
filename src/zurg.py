class Toy:
    def __init__(self, name: str, speed: int):
        self.name = name
        self.speed = speed

    def __str__(self):
        return self.name


class Action:
    def __init__(self, toys: list[Toy]):
        self.toys = toys

    def __str__(self):
        raise NotImplementedError


class LeftToRight(Action):
    def __init__(self, toy1: Toy, toy2: Toy):
        super().__init__(toys=[toy1, toy2])

    def __str__(self):
        return f"left_to_right({self.toys[0]}, {self.toys[1]})"


class RightToLeft(Action):
    def __init__(self, toy: Toy):
        super().__init__(toys=[toy])

    def __str__(self):
        return f"right_to_left({self.toys[0]})"


def dfs(limit: int, toys: list[Toy]):
    # (time, left, right, actions, 'direction')
    start = (0, toys, [], [], 'left', 0)
    stack = [start]

    solutions = []

    while len(stack):
        time, left, right, actions, direction, depth = stack.pop()
        if len(left) == 0 and direction == 'right':
            solutions.append((actions, time))
            continue
        if direction == 'left':
            for i in range(len(left)):
                t1 = left[i]
                for j in range(i + 1, len(left)):
                    t2 = left[j]
                    new_time = time + max(t1.speed, t2.speed)
                    new_left = [t for t in left if t.name != t1.name and t.name != t2.name]
                    new_right = right + [t1, t2]
                    new_s = (new_time, new_left, new_right, actions + [LeftToRight(t1, t2)], 'right', depth + 1)
                    if new_time <= limit:
                        stack.append(new_s)
        elif direction == 'right':
            for i in range(len(right)):
                t = right[i]
                new_time = time + t.speed
                new_left = left + [t]
                new_right = [x for x in right if x.name != t.name]
                new_s = (new_time, new_left, new_right, actions + [RightToLeft(t)], 'left', depth + 1)
                if new_time <= limit:
                    stack.append(new_s)

    return solutions


if __name__ == "__main__":
    time_limit: int = 60
    toys: list[Toy] = [
        Toy(name='buzz', speed=5),
        Toy(name='woody', speed=10),
        Toy(name='rex', speed=20),
        Toy(name='hamm', speed=25),
    ]

    solutions = dfs(time_limit, toys)

    for solution, cost in solutions:
        print(f'Solution [{cost}]:')
        for action in solution:
            print(f'{action} -> ', end='')
        print()
