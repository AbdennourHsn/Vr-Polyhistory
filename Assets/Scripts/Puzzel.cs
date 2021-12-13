using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Puzzel : MonoBehaviour
{
    public Piece[] p;
    private bool canMove;
    public Piece EmptyPiece;
    public UnityEvent IsSolved;
    private void Start()
    {
        foreach (Piece p in p) if (p.isEmpty)
            {
                EmptyPiece = p;
                break;
            }
        for (int i = 0; i < p.Length; i++)
        {
            p[i].currPos = i;
            p[i].rightPosition = i;
        }
        RandomPuzzel();
        canMove = true;
    }
    public void RandomPuzzel()
    {
        EmptyPiece.MoveUp();
        EmptyPiece.MoveLeft();
        EmptyPiece.MoveDown();
    }
    public void check()
    {
        bool win=true;
        foreach(Piece p in p)
        {
            if (p.currPos != p.rightPosition) win = false;
        }

        if (win)
        {
            canMove = false;
            StartCoroutine(Solved());
        }
    }

    IEnumerator Solved()
    {
        yield return new WaitForSeconds(1.2f);
        EmptyPiece.gameObject.GetComponent<MeshRenderer>().enabled = true;
        IsSolved.Invoke();

    }
    public void SetCanMove(bool move) { canMove = move; }
    public bool Canmove() { return canMove; }
}
